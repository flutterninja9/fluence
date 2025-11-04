import asyncio
import tempfile
import os
import time
import docker
from typing import Dict, Optional
from config import settings

class DartCodeRunner:
    """Secure Dart code execution in Docker container"""
    
    def __init__(self):
        self.client = docker.from_env()
        self.image_name = "dart:stable"
        # Build our custom sandbox image if it doesn't exist
        self._ensure_sandbox_image()
    
    async def run_code(self, code: str, test_script: Optional[str] = None) -> Dict:
        """Execute Dart code safely in Docker container"""
        start_time = time.time()
        
        try:
            # Create temporary directory for code files
            with tempfile.TemporaryDirectory() as temp_dir:
                # Write main code file
                main_file = os.path.join(temp_dir, "main.dart")
                with open(main_file, "w") as f:
                    f.write(code)
                
                # Write test file if provided
                test_file = None
                if test_script:
                    test_file = os.path.join(temp_dir, "test.dart")
                    with open(test_file, "w") as f:
                        f.write(test_script)
                
                # Run in Docker container
                result = await self._execute_in_container(temp_dir, test_file is not None)
                
                execution_time = time.time() - start_time
                
                return {
                    "success": result["exit_code"] == 0,
                    "output": result["stdout"],
                    "errors": result["stderr"] if result["stderr"] else None,
                    "execution_time": execution_time
                }
        
        except Exception as e:
            execution_time = time.time() - start_time
            return {
                "success": False,
                "output": "",
                "errors": f"Execution error: {str(e)}",
                "execution_time": execution_time
            }
    
    async def _execute_in_container(self, code_dir: str, has_test: bool) -> Dict:
        """Execute code in Docker container with security restrictions"""
        
        # Command to run
        if has_test:
            command = ["sh", "-c", "dart test.dart && dart main.dart"]
        else:
            command = ["dart", "main.dart"]
        
        try:
            # Run container with security restrictions
            container = self.client.containers.run(
                self.image_name,
                command=command,
                volumes={code_dir: {'bind': '/app', 'mode': 'ro'}},
                working_dir='/app',
                detach=True,
                remove=True,
                mem_limit=f"{settings.MAX_MEMORY_MB}m",
                cpu_quota=50000,  # 50% of CPU
                network_disabled=True,  # No network access
                read_only=True,  # Read-only filesystem
                user="nobody",  # Run as non-root user
                cap_drop=["ALL"],  # Drop all capabilities
            )
            
            # Wait for completion with timeout
            try:
                result = container.wait(timeout=settings.EXECUTION_TIMEOUT)
                exit_code = result['StatusCode']
                
                # Get output
                stdout = container.logs(stdout=True, stderr=False).decode('utf-8')
                stderr = container.logs(stdout=False, stderr=True).decode('utf-8')
                
                return {
                    "exit_code": exit_code,
                    "stdout": stdout,
                    "stderr": stderr
                }
            
            except Exception:
                # Kill container if timeout
                container.kill()
                return {
                    "exit_code": 1,
                    "stdout": "",
                    "stderr": "Code execution timed out"
                }
        
        except docker.errors.ContainerError as e:
            return {
                "exit_code": e.exit_status,
                "stdout": "",
                "stderr": f"Container error: {e.stderr.decode('utf-8') if e.stderr else str(e)}"
            }
        
        except Exception as e:
            return {
                "exit_code": 1,
                "stdout": "",
                "stderr": f"Docker execution error: {str(e)}"
            }
    
    def _ensure_sandbox_image(self):
        """Build sandbox image if it doesn't exist"""
        try:
            self.client.images.get("fluence-dart-sandbox")
            self.image_name = "fluence-dart-sandbox"
        except docker.errors.ImageNotFound:
            # Use the default dart image for now
            pass