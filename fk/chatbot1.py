import json
import os
from typing import Dict, List, Optional
from datetime import datetime
import time
from colorama import init, Fore, Back, Style
import textwrap
import sys
import dotenv
from together import Together

# Initialize colorama for cross-platform color support
init()

class AIChatbot:
    def __init__(self):
        # Load environment variables from .env file
        dotenv.load_dotenv()
        
        # Initialize API configuration
        self.api_key = os.getenv('TOGETHER_API_KEY')
        self.model = "meta-llama/Llama-3.3-70B-Instruct-Turbo"
        self.max_tokens = 4096
        self.temperature = 0.7
        self.conversation_history = []
        self.wrapper = textwrap.TextWrapper(width=70, subsequent_indent=' ' * 4)
        
        # Initialize Together AI client
        self.client = Together()

    def print_banner(self):
        """Print a stylized banner for the chatbot"""
        banner = """
╔══════════════════════════════════════════════════════════════╗
║                       AI Assistant                           ║
║                                                              ║
║              Your Personal AI Chat Assistant                 ║
╚══════════════════════════════════════════════════════════════╝
"""
        print(Fore.CYAN + banner + Style.RESET_ALL)
        print(Fore.YELLOW + "Type 'help' for commands or 'quit' to exit\n" + Style.RESET_ALL)

    def print_thinking_animation(self):
        """Show a thinking animation while waiting for API response"""
        print(Fore.CYAN + "Thinking", end='')
        for _ in range(3):
            time.sleep(0.3)
            print(".", end='', flush=True)
        print(Style.RESET_ALL)

    def format_message(self, role: str, content: str) -> str:
        """Format a message with proper styling"""
        role_colors = {
            "user": Fore.GREEN,
            "assistant": Fore.BLUE,
            "system": Fore.YELLOW
        }
        
        color = role_colors.get(role, Fore.WHITE)
        formatted_content = self.wrapper.fill(content)
        
        output = f"\n{color}╭─ {role.title()}{Style.RESET_ALL}\n"
        for line in formatted_content.split('\n'):
            output += f"{color}│{Style.RESET_ALL}  {line}\n"
        output += f"{color}╰{'─' * 50}{Style.RESET_ALL}\n"
        
        return output

    def generate_system_prompt(self) -> str:
        """Generate the system prompt for the model"""
        return """You are a helpful, respectful and honest assistant. Always provide accurate information and admit when you're not sure about something. Keep responses clear and concise unless asked for more detail."""

    def prepare_messages(self, user_input: str) -> List[Dict[str, str]]:
        """Prepare messages for the API request"""
        messages = [
            {"role": "system", "content": self.generate_system_prompt()}
        ]
        
        # Add relevant conversation history
        for msg in self.conversation_history[-5:]:  # Keep last 5 exchanges for context
            messages.append(msg)
            
        # Add current user input
        messages.append({"role": "user", "content": user_input})
        
        return messages

    def call_api(self, messages: List[Dict[str, str]]) -> Optional[str]:
        """Make API call to the model using Together AI"""
        try:
            response = self.client.chat.completions.create(
                model=self.model,
                messages=messages,
                temperature=self.temperature,
                max_tokens=self.max_tokens
            )
            
            return response.choices[0].message.content
            
        except Exception as e:
            print(f"{Fore.RED}Error calling API: {e}{Style.RESET_ALL}")
            return None

    def save_conversation(self):
        """Save conversation history to a file"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"conversation_{timestamp}.json"
        
        try:
            with open(filename, 'w') as f:
                json.dump(self.conversation_history, f, indent=2)
            print(f"{Fore.GREEN}Conversation saved to {filename}{Style.RESET_ALL}")
        except Exception as e:
            print(f"{Fore.RED}Error saving conversation: {e}{Style.RESET_ALL}")

    def print_help(self):
        """Display available commands"""
        help_text = f"""
{Fore.GREEN}Available Commands:{Style.RESET_ALL}
• /clear - Clear conversation history
• /save - Save conversation to file
• /system <prompt> - Set new system prompt
• /temp <0.0-1.0> - Adjust temperature
• help - Show this help message
• quit - Exit

{Fore.GREEN}Tips:{Style.RESET_ALL}
• Be specific in your questions
• Use clear and concise language
• Multi-line input is supported (press Enter twice to submit)
"""
        print(help_text)

    def process_command(self, command: str) -> bool:
        """Process special commands"""
        if command.startswith('/'):
            cmd_parts = command[1:].split(maxsplit=1)
            cmd = cmd_parts[0].lower()
            
            if cmd == 'clear':
                self.conversation_history.clear()
                print(f"{Fore.GREEN}Conversation history cleared.{Style.RESET_ALL}")
                return True
                
            elif cmd == 'save':
                self.save_conversation()
                return True
                
            elif cmd == 'system' and len(cmd_parts) > 1:
                new_prompt = cmd_parts[1]
                self.system_prompt = new_prompt
                print(f"{Fore.GREEN}System prompt updated.{Style.RESET_ALL}")
                return True
                
            elif cmd == 'temp' and len(cmd_parts) > 1:
                try:
                    new_temp = float(cmd_parts[1])
                    if 0 <= new_temp <= 1:
                        self.temperature = new_temp
                        print(f"{Fore.GREEN}Temperature set to {new_temp}{Style.RESET_ALL}")
                    else:
                        print(f"{Fore.RED}Temperature must be between 0 and 1{Style.RESET_ALL}")
                except ValueError:
                    print(f"{Fore.RED}Invalid temperature value{Style.RESET_ALL}")
                return True
                
        return False

    def get_multiline_input(self) -> str:
        """Get multi-line input from user"""
        print(f"{Fore.GREEN}┌─ Input{Style.RESET_ALL} (Press Enter twice to submit)")
        lines = []
        while True:
            line = input(f"{Fore.GREEN}│{Style.RESET_ALL} " if lines else f"{Fore.GREEN}└→{Style.RESET_ALL} ")
            if not line and lines:  # Empty line and we have content
                break
            if line:
                lines.append(line)
        return '\n'.join(lines)

    def chat(self):
        """Main chat loop"""
        self.print_banner()
        
        while True:
            try:
                # Get user input
                user_input = self.get_multiline_input().strip()
                
                if not user_input:
                    continue
                    
                if user_input.lower() == 'quit':
                    print(f"\n{Fore.CYAN}Thanks for chatting! Goodbye!{Style.RESET_ALL}")
                    break
                    
                if user_input.lower() == 'help':
                    self.print_help()
                    continue
                
                # Check for special commands
                if self.process_command(user_input):
                    continue
                
                # Print user message
                print(self.format_message("user", user_input))
                
                # Get response from API
                self.print_thinking_animation()
                messages = self.prepare_messages(user_input)
                response = self.call_api(messages)
                
                if response:
                    # Store in conversation history
                    self.conversation_history.append({"role": "user", "content": user_input})
                    self.conversation_history.append({"role": "assistant", "content": response})
                    
                    # Print response
                    print(self.format_message("assistant", response))
                else:
                    print(f"{Fore.RED}Failed to get response from the API.{Style.RESET_ALL}")
                
            except KeyboardInterrupt:
                print(f"\n\n{Fore.CYAN}Chat terminated by user. Goodbye!{Style.RESET_ALL}")
                break
            except Exception as e:
                print(f"{Fore.RED}An error occurred: {e}{Style.RESET_ALL}")

def main():
    # Check for API key
    if not os.getenv('TOGETHER_API_KEY'):
        print(f"{Fore.RED}Error: TOGETHER_API_KEY not found in environment variables.")
        print("Please create a .env file with your API key or set it in your environment.{Style.RESET_ALL}")
        return
        
    chatbot = AIChatbot()
    chatbot.chat()

if __name__ == "__main__":
    main()