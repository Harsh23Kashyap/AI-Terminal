#!/usr/bin/env python3
"""
AI Helper Script for Terminal Commands (Gemini version)
Provides intelligent assistance for shell operations using Google Gemini
"""

import sys
import subprocess
import os
import time
import threading
import concurrent.futures
from google import genai
try:
    from openai import OpenAI  # v1 client
except Exception:
    OpenAI = None
try:
    from rich.console import Console
    from rich.markdown import Markdown
    _RICH_AVAILABLE = True
except Exception:
    _RICH_AVAILABLE = False

GEMINI_MODEL = "gemini-2.5-flash"
# Read API keys from environment only; never hardcode defaults that look like real keys
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY") or ""
try:
    client = genai.Client(api_key=GEMINI_API_KEY) if GEMINI_API_KEY else None
except Exception:
    client = None

class TerminalAI:
    def __init__(self):
        self.context = self._get_system_context()
        try:
            self.client = client
        except Exception:
            self.client = None
        # Initialize OpenAI v1 client using provided env key only (no hardcoded defaults)
        try:
            if OpenAI is not None:
                api_key = os.environ.get("OPENAI_API_KEY")
                if not api_key:
                    self.openai_client = None
                else:
                    self.openai_client = OpenAI(api_key=api_key)
            else:
                self.openai_client = None
        except Exception:
            self.openai_client = None
        self.last_status = None  # track which provider answered / why

    def _start_spinner(self, phases=("Thinking", "Analysing"), interval=0.5):
        stop_event = threading.Event()

        def _spin():
            i = 0
            dots = [".", "..", "..."]
            while not stop_event.is_set():
                phase = phases[(i // 3) % len(phases)]
                msg = f"{phase} {dots[i % 3]}"
                try:
                    sys.stdout.write("\r" + msg + " " * 10)
                    sys.stdout.flush()
                except Exception:
                    pass
                time.sleep(interval)
                i += 1
            # clear the line when done
            try:
                sys.stdout.write("\r" + " " * 80 + "\r")
                sys.stdout.flush()
            except Exception:
                pass

        thread = threading.Thread(target=_spin, daemon=True)
        thread.start()
        return stop_event
    
    def _get_system_context(self):
        """Get current system context for better AI responses"""
        try:
            # Get current directory
            cwd = os.getcwd()
            
            # Get shell type
            shell = os.environ.get('SHELL', 'unknown')
            
            # Get OS info
            os_info = subprocess.run(['uname', '-a'], capture_output=True, text=True).stdout.strip()
            
            # Get current user
            user = os.environ.get('USER', 'unknown')
            
            return {
                'cwd': cwd,
                'shell': shell,
                'os': os_info,
                'user': user
            }
        except:
            return {}

    def ask_question(self, question):
        """Handle general AI questions about terminal/development"""
        if self.client is None and self.openai_client is None:
            return "Error: No AI client is initialized. Please ensure the client is set."

        prompt = f"""You are an expert terminal and development assistant. The user is asking: "{question}"

Current context:
- Working directory: {self.context.get('cwd', 'unknown')}
- Shell: {self.context.get('shell', 'unknown')}
- OS: {self.context.get('os', 'unknown')}
- User: {self.context.get('user', 'unknown')}

Please respond using clean Markdown with concise headings (##/###), bullet lists, and fenced bash code blocks for commands (```bash). Keep it skimmable and practical with executable steps for macOS."""

        try:
            return self._generate_with_fallback(prompt)
        except Exception as e:
            return f"Error generating response: {str(e)}"

    def debug_issue(self, error_output):
        """Debug terminal errors and provide solutions"""
        if self.client is None and self.openai_client is None:
            return "Error: No AI client is initialized. Please ensure the client is set."

        prompt = f"""You are an expert system administrator and debugger. The user encountered this terminal error or issue:

ERROR/ISSUE:
{error_output}

Current system context:
- Working directory: {self.context.get('cwd', 'unknown')}
- Shell: {self.context.get('shell', 'unknown')}
- OS: {self.context.get('os', 'unknown')}
- User: {self.context.get('user', 'unknown')}

Please analyze this error and provide:

1. DIAGNOSIS: What is causing this error
2. IMMEDIATE SOLUTION: The exact command(s) to fix this issue
3. EXPLANATION: Why this error occurred
4. PREVENTION: How to avoid this in the future
5. ALTERNATIVES: Other ways to accomplish what the user was trying to do

Use clean Markdown and fenced bash code blocks for commands that are executable on macOS."""

        try:
            return self._generate_with_fallback(prompt)
        except Exception as e:
            return f"Error generating response: {str(e)}"

    def execute_and_analyze(self, command):
        """Execute a command and analyze its output with AI"""
        if self.client is None and self.openai_client is None:
            return "Error: No AI client is initialized. Please ensure the client is set."

        # Get current shell prompt info
        user = os.environ.get('USER', 'user')
        hostname = os.environ.get('HOSTNAME', 'MacBook-Pro')
        cwd = os.path.basename(os.getcwd())
        venv = os.environ.get('VIRTUAL_ENV', '')
        venv_name = os.path.basename(venv) if venv else ''
        
        # Display command as it would appear in terminal
        if venv_name:
            print(f"({venv_name}) {user}@{hostname} {cwd} % {command}")
        else:
            print(f"{user}@{hostname} {cwd} % {command}")
        
        # Execute the command FIRST - show output immediately
        try:
            result = subprocess.run(
                command,
                shell=True,
                capture_output=True,
                text=True,
                timeout=30,  # 30 second timeout
                cwd=self.context.get('cwd', os.getcwd())
            )
            
            # Capture execution details
            return_code = result.returncode
            stdout = result.stdout
            stderr = result.stderr
            
            # Display the output with ultra-unique terminal design
            if _RICH_AVAILABLE:
                console = Console()
                # Ultra-unique terminal window design
                console.print("╔" + "═" * 76 + "╗", style="bold bright_blue")
                console.print("║" + " " * 76 + "║", style="bright_blue")
                console.print("║" + " " * 25 + "🖥️  ═══ TERMINAL OUTPUT ═══" + " " * 25 + "║", style="bold bright_yellow on bright_blue")
                console.print("║" + " " * 76 + "║", style="bright_blue")
                console.print("╠" + "═" * 76 + "╣", style="bold bright_blue")
                
                # Display the actual command output with unique styling
                if stdout:
                    for line in stdout.split('\n'):
                        if line.strip():  # Only print non-empty lines
                            console.print(f"║ {line}", style="bright_white")
                if stderr:
                    for line in stderr.split('\n'):
                        if line.strip():  # Only print non-empty lines
                            console.print(f"║ {line}", style="bold bright_red")
                
                console.print("╚" + "═" * 76 + "╝", style="bold bright_blue")
                console.print("", style="dim")  # Add some spacing
                console.print("┌─" + "─" * 74 + "─┐", style="dim")
                console.print("│ " + " " * 74 + " │", style="dim")
                console.print("│ " + " " * 30 + "🤖 AI ANALYSIS BELOW" + " " * 24 + " │", style="dim")
                console.print("│ " + " " * 74 + " │", style="dim")
                console.print("└─" + "─" * 74 + "─┘", style="dim")
            else:
                # Fallback for systems without rich
                print("╔" + "═" * 76 + "╗")
                print("║" + " " * 76 + "║")
                print("║" + " " * 25 + "🖥️  ═══ TERMINAL OUTPUT ═══" + " " * 25 + "║")
                print("║" + " " * 76 + "║")
                print("╠" + "═" * 76 + "╣")
                
                # Display the actual command output
                if stdout:
                    for line in stdout.split('\n'):
                        if line.strip():  # Only print non-empty lines
                            print(f"║ {line}")
                if stderr:
                    for line in stderr.split('\n'):
                        if line.strip():  # Only print non-empty lines
                            print(f"║ {line}")
                
                print("╚" + "═" * 76 + "╝")
                print("")
                print("┌─" + "─" * 74 + "─┐")
                print("│ " + " " * 74 + " │")
                print("│ " + " " * 30 + "🤖 AI ANALYSIS BELOW" + " " * 30 + " │")
                print("│ " + " " * 74 + " │")
                print("└─" + "─" * 74 + "─┘")
            
            print()
            
            # Force flush output to ensure it shows immediately
            sys.stdout.flush()
            
            # Determine success based on return code (0 = success, non-zero = failure)
            success = return_code == 0
            status = "SUCCESS" if success else "FAILED"
            
            # NOW analyze with AI (after showing command output)
            prompt = f"""You are an expert system administrator and command analyst. A command was just executed and you need to analyze the results.

COMMAND EXECUTED: {command}
EXECUTION STATUS: {status}
RETURN CODE: {return_code}

STDOUT:
{stdout if stdout else '(no output)'}

STDERR:
{stderr if stderr else '(no errors)'}

Current system context:
- Working directory: {self.context.get('cwd', 'unknown')}
- Shell: {self.context.get('shell', 'unknown')}
- OS: {self.context.get('os', 'unknown')}
- User: {self.context.get('user', 'unknown')}

CRITICAL: The verdict must be based on the return code:
- Return code 0 = SUCCESS (command completed successfully)
- Return code non-zero = FAILED (command failed, regardless of output content)

Commands like 'git main' fail with return code 1 and show error messages in stdout, not stderr. This is still a FAILURE.

Please provide a comprehensive analysis in the following format:

## EXECUTION VERDICT
**Status:** {status}
**Command:** `{command}`
**Return Code:** {return_code}

## ANALYSIS
- **What happened:** Brief explanation of what the command did
- **Success/Failure reason:** Why it succeeded or failed (MUST consider return code)
- **Output interpretation:** What the output means

## RECOMMENDATIONS
- **What could be done differently:** Suggestions for improvement
- **Alternative approaches:** Other ways to achieve the same goal
- **Next steps:** What to do next

## COMMAND BREAKDOWN
- **Purpose:** What this command is designed to do
- **Key components:** Important parts of the command
- **Safety notes:** Any potential risks or considerations

CRITICAL: At the very end of your response, add a verdict line in this exact format:
- If return code is 0: VERDICT: SUCCESS
- If return code is non-zero: VERDICT: FAILED

The verdict MUST match the return code, not the content of the output.

Use clean Markdown formatting with fenced bash code blocks for commands. Ensure macOS compatibility."""

            try:
                analysis = self._generate_with_fallback(prompt)
                return analysis
            except Exception as e:
                return f"Error generating AI analysis: {str(e)}"
                
        except subprocess.TimeoutExpired:
            error_msg = f"Command timed out after 30 seconds: {command}"
            print(error_msg)
            if _RICH_AVAILABLE:
                console = Console()
                console.print(f"⏰ [bold yellow]Command timed out![/bold yellow]")
            else:
                print("⏰ Command timed out!")
            return f"## EXECUTION VERDICT\n**Status:** TIMEOUT\n**Command:** `{command}`\n\n## ANALYSIS\n- **What happened:** The command exceeded the 30-second timeout limit\n- **Recommendation:** Consider breaking down the command or using a different approach for long-running operations"
            
        except Exception as e:
            error_msg = f"Error executing command: {str(e)}"
            print(error_msg)
            if _RICH_AVAILABLE:
                console = Console()
                console.print(f"💥 [bold red]Execution error![/bold red]")
            else:
                print("💥 Execution error!")
            return f"## EXECUTION VERDICT\n**Status:** ERROR\n**Command:** `{command}`\n\n## ANALYSIS\n- **What happened:** An error occurred while trying to execute the command\n- **Error details:** {str(e)}\n- **Recommendation:** Check command syntax and system permissions"

    def help_command(self, command, error_output=None):
        """Get help with a specific command and optionally debug its error"""
        if error_output:
            # Command failed, debug it
            prompt = f"""You are an expert terminal command specialist. The user tried to run this command but it failed:

COMMAND ATTEMPTED: {command}
ERROR OUTPUT: {error_output}

Current system context:
- Working directory: {self.context.get('cwd', 'unknown')}
- Shell: {self.context.get('shell', 'unknown')}
- OS: {self.context.get('os', 'unknown')}
- User: {self.context.get('user', 'unknown')}

Provide:

1. ERROR ANALYSIS: What went wrong with this specific command
2. CORRECTED COMMAND: The exact fixed version of the command
3. EXPLANATION: Why the original command failed
4. COMMAND BREAKDOWN: Explain each part of the corrected command
5. USAGE EXAMPLES: 3-5 practical examples of how to use this command correctly
6. COMMON MISTAKES: Other common errors with this command and how to avoid them
7. RELATED COMMANDS: Similar or complementary commands that might be useful

Respond in clean Markdown. Use fenced bash code blocks for commands (```bash). Ensure macOS compatibility."""
        else:
            # Just explain the command
            prompt = f"""You are an expert terminal command instructor. The user wants to learn about this command: {command}

Current system context:
- Working directory: {self.context.get('cwd', 'unknown')}
- Shell: {self.context.get('shell', 'unknown')}
- OS: {self.context.get('os', 'unknown')}

Provide a concise Markdown guide including:

1. COMMAND PURPOSE
2. BASIC SYNTAX with real examples
3. COMMON OPTIONS
4. 5-7 PRACTICAL EXAMPLES
5. ADVANCED USAGE
6. SAFETY NOTES
7. RELATED COMMANDS
8. TROUBLESHOOTING

Use fenced bash blocks for commands. Ensure macOS compatibility."""

        if self.client is None and self.openai_client is None:
            return "Error: No AI client is initialized. Please ensure the client is set."

        try:
            return self._generate_with_fallback(prompt)
        except Exception as e:
            return f"Error generating response: {str(e)}"

    def _generate_with_fallback(self, prompt: str) -> str:
        # Try OpenAI first with retry/backoff; otherwise fallback to Gemini
        if self.openai_client is not None:
            delay = 0.5
            last_exc = None
            start_openai = time.monotonic()
            spinner_stop = self._start_spinner(("Thinking", "Analysing"), interval=0.5)
            for _ in range(3):
                try:
                    resp = self.openai_client.chat.completions.create(
                        model="gpt-4o",
                        messages=[
                            {"role": "system", "content": "You are a helpful assistant."},
                            {"role": "user", "content": prompt},
                        ],
                        # temperature=1,
                        # max_completion_tokens=800,
                    )
                    text = resp.choices[0].message.content
                    duration_ms = int((time.monotonic() - start_openai) * 1000)
                    spinner_stop.set()
                    self.last_status = {"provider": "openai", "reason": "ok", "duration_ms": duration_ms}
                    return text
                except Exception as exc:
                    last_exc = exc
                    time.sleep(delay)
                    delay *= 2
            spinner_stop.set()
            # OpenAI failed: fallback to Gemini
            self.last_status = {"provider": "gemini", "reason": "openai_failed", "error": str(last_exc)}
        
        # Gemini fallback with strict timeout
        if self.client is None:
            raise RuntimeError("No AI client is available (both OpenAI and Gemini failed).")
        
        start = time.monotonic()
        spinner_stop = self._start_spinner(("Thinking", "Analysing"), interval=0.5)
        with concurrent.futures.ThreadPoolExecutor(max_workers=1) as pool:
            fut = pool.submit(self.client.models.generate_content, model=GEMINI_MODEL, contents=prompt)
            try:
                resp = fut.result(timeout=7.0)
                spinner_stop.set()
                duration_ms = int((time.monotonic() - start) * 1000)
                if not self.last_status:
                    self.last_status = {"provider": "gemini", "reason": "ok", "duration_ms": duration_ms}
                else:
                    self.last_status["duration_ms"] = duration_ms
                return getattr(resp, "text", str(resp))
            except concurrent.futures.TimeoutError:
                spinner_stop.set()
                raise RuntimeError("Gemini fallback timed out after 7 seconds")
            except Exception as e:
                spinner_stop.set()
                raise RuntimeError(f"Gemini fallback failed: {str(e)}")

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 ~/ai_helper.py <mode> <input>")
        print("Modes: ask, debug, help")
        sys.exit(1)
    
    mode = sys.argv[1]
    ai = TerminalAI()
    console = Console() if _RICH_AVAILABLE else None
    
    if mode == "ask":
        if len(sys.argv) < 3:
            print("Usage: aiask <question>")
            sys.exit(1)
        question = " ".join(sys.argv[2:])
        response = ai.ask_question(question)
        if console and ai.last_status and ai.last_status.get("provider") == "gemini":
            reason = ai.last_status.get("reason", "")
            console.print("[bold magenta]⏩ Falling back to Gemini (" + reason + ")[/bold magenta]")
        if console:
            if isinstance(response, str) and response.startswith("Error generating response:"):
                console.print("[bold red]" + response + "[/bold red]")
            else:
                console.print(Markdown(response), style="default")
        else:
            print(response)
    
    elif mode == "debug":
        if len(sys.argv) < 3:
            print("Usage: aidebug <error_output>")
            sys.exit(1)
        error = " ".join(sys.argv[2:])
        response = ai.debug_issue(error)
        if console and ai.last_status and ai.last_status.get("provider") == "gemini":
            reason = ai.last_status.get("reason", "")
            console.print("[bold magenta]⏩ Falling back to Gemini (" + reason + ")[/bold magenta]")
        if console:
            if isinstance(response, str) and response.startswith("Error generating response:"):
                console.print("[bold red]" + response + "[/bold red]")
            else:
                console.print(Markdown(response), style="default")
        else:
            print(response)
    
    
    elif mode == "help":
        if len(sys.argv) < 3:
            print("Usage: aihelp <command>")
            sys.exit(1)
        command = " ".join(sys.argv[2:])
        response = ai.execute_and_analyze(command)
        if console and ai.last_status and ai.last_status.get("provider") == "gemini":
            reason = ai.last_status.get("reason", "")
            console.print("[bold magenta]⏩ Falling back to Gemini (" + reason + ")[/bold magenta]")
        
        # Parse verdict from AI response and display it
        if isinstance(response, str) and not response.startswith("Error generating response:"):
            # Look for VERDICT: in the response
            if "VERDICT: SUCCESS" in response:
                if console:
                    console.print("✅ [bold green]Command executed successfully![/bold green]")
                else:
                    print("✅ Command executed successfully!")
            elif "VERDICT: FAILED" in response:
                if console:
                    console.print("❌ [bold red]Command failed![/bold red]")
                else:
                    print("❌ Command failed!")
            
            # Remove the VERDICT line from the response before displaying
            response = response.replace("VERDICT: SUCCESS", "").replace("VERDICT: FAILED", "").strip()
        
        if console:
            if isinstance(response, str) and response.startswith("Error generating response:"):
                console.print("[bold red]" + response + "[/bold red]")
            else:
                console.print(Markdown(response), style="default")
        else:
            print(response)
    
    else:
        print(f"Unknown mode: {mode}")
        print("Available modes: ask, debug, help")
        sys.exit(1)

if __name__ == "__main__":
    main()
