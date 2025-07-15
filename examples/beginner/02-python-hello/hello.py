#!/usr/bin/env python3
"""
Simple Python Hello World script for Docker containerization learning.
Demonstrates basic Python application structure and Docker best practices.
"""

import os
import sys
import time
from datetime import datetime

def main():
    """Main function demonstrating basic Python containerization."""
    
    print("🐍 Python Docker Hello World! 🐳")
    print("=" * 50)
    
    # Display Python information
    print(f"Python Version: {sys.version}")
    print(f"Python Executable: {sys.executable}")
    print(f"Platform: {sys.platform}")
    
    # Display container information
    print("\n🐳 Container Information:")
    print(f"Current Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Working Directory: {os.getcwd()}")
    print(f"User ID: {os.getuid()}")
    print(f"Process ID: {os.getpid()}")
    
    # Display environment variables
    print("\n🔧 Environment Variables:")
    important_vars = [
        'PYTHONPATH', 'PYTHONUNBUFFERED', 'PYTHONDONTWRITEBYTECODE',
        'PATH', 'HOME', 'USER'
    ]
    
    for var in important_vars:
        value = os.environ.get(var, 'Not set')
        print(f"  {var}: {value}")
    
    # Demonstrate basic file operations
    print("\n📁 File System Check:")
    try:
        files = os.listdir('.')
        print(f"Files in current directory: {files}")
    except PermissionError:
        print("Permission denied accessing current directory")
    
    # Simple computation demonstration
    print("\n🧮 Simple Computation:")
    numbers = [1, 2, 3, 4, 5]
    total = sum(numbers)
    average = total / len(numbers)
    print(f"Numbers: {numbers}")
    print(f"Sum: {total}")
    print(f"Average: {average}")
    
    # Demonstrate command line arguments
    print(f"\n📋 Command Line Arguments:")
    print(f"Script name: {sys.argv[0]}")
    if len(sys.argv) > 1:
        print(f"Arguments: {sys.argv[1:]}")
    else:
        print("No additional arguments provided")
    
    # Interactive demonstration (if running interactively)
    if os.isatty(sys.stdin.fileno()):
        print("\n🎯 Interactive Mode Detected!")
        try:
            name = input("Enter your name (or press Enter to skip): ")
            if name.strip():
                print(f"Hello, {name}! Welcome to Docker with Python! 🎉")
        except (EOFError, KeyboardInterrupt):
            print("\nInput skipped.")
    else:
        print("\n🤖 Running in non-interactive mode")
    
    # Simulate some work
    print("\n⏳ Simulating work...")
    for i in range(3):
        time.sleep(1)
        print(f"  Processing step {i + 1}/3...")
    
    print("\n✅ Python Docker container executed successfully!")
    print("🎓 Key concepts demonstrated:")
    print("  - Python environment in Docker")
    print("  - Environment variable handling")
    print("  - File system operations")
    print("  - User permissions and security")
    print("  - Interactive vs non-interactive execution")
    print("  - Basic Python application structure")
    
    return 0

if __name__ == "__main__":
    try:
        exit_code = main()
        sys.exit(exit_code)
    except KeyboardInterrupt:
        print("\n\n👋 Goodbye! Container interrupted by user.")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Error: {e}")
        sys.exit(1)
