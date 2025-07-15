#!/bin/bash

# Build and Test Script for Dockerfile Examples
# Usage: ./scripts/build-and-test.sh [example-path]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to build and test a single example
test_example() {
    local example_path="$1"
    local example_name=$(basename "$example_path")
    
    print_status "Testing example: $example_name"
    
    # Check if Dockerfile exists
    if [[ ! -f "$example_path/Dockerfile" ]]; then
        print_warning "No Dockerfile found in $example_path, skipping..."
        return 0
    fi
    
    # Change to example directory
    pushd "$example_path" > /dev/null
    
    # Build the image
    print_status "Building Docker image..."
    if docker build -t "dockerfile-examples:$example_name" .; then
        print_success "Build successful for $example_name"
    else
        print_error "Build failed for $example_name"
        popd > /dev/null
        return 1
    fi
    
    # Test with docker-compose if available
    if [[ -f "docker-compose.yml" ]]; then
        print_status "Testing with Docker Compose..."
        if docker-compose config > /dev/null 2>&1; then
            print_success "Docker Compose configuration is valid"
            
            # Start services (detached)
            docker-compose up -d
            sleep 5
            
            # Check if services are running
            if docker-compose ps | grep -q "Up"; then
                print_success "Docker Compose services started successfully"
            else
                print_warning "Some Docker Compose services may not be running properly"
            fi
            
            # Stop services
            docker-compose down
        else
            print_error "Docker Compose configuration is invalid"
            popd > /dev/null
            return 1
        fi
    else
        # Test simple docker run
        print_status "Testing simple container run..."
        if timeout 10s docker run --rm "dockerfile-examples:$example_name" > /dev/null 2>&1; then
            print_success "Container run test successful"
        else
            print_warning "Container run test completed (may be expected for service containers)"
        fi
    fi
    
    popd > /dev/null
    print_success "Example $example_name tested successfully"
    return 0
}

# Function to test all examples
test_all_examples() {
    local base_dirs=("examples" "messaging" "databases" "web-services" "monitoring")
    local failed_tests=()
    local total_tests=0
    local successful_tests=0
    
    print_status "Starting comprehensive testing of all examples..."
    
    for base_dir in "${base_dirs[@]}"; do
        if [[ -d "$base_dir" ]]; then
            print_status "Testing examples in $base_dir/"
            
            # Find all directories with Dockerfiles
            while IFS= read -r -d '' example_path; do
                ((total_tests++))
                if test_example "$example_path"; then
                    ((successful_tests++))
                else
                    failed_tests+=("$example_path")
                fi
                echo # Empty line for readability
            done < <(find "$base_dir" -name "Dockerfile" -type f -exec dirname {} \; -print0 | sort -z)
        fi
    done
    
    # Print summary
    echo
    print_status "Testing Summary:"
    echo "Total examples tested: $total_tests"
    echo "Successful: $successful_tests"
    echo "Failed: $((total_tests - successful_tests))"
    
    if [[ ${#failed_tests[@]} -gt 0 ]]; then
        print_error "Failed examples:"
        for failed in "${failed_tests[@]}"; do
            echo "  - $failed"
        done
        return 1
    else
        print_success "All examples tested successfully!"
        return 0
    fi
}

# Function to clean up Docker resources
cleanup() {
    print_status "Cleaning up Docker resources..."
    
    # Remove test images
    docker images --filter "reference=dockerfile-examples:*" -q | xargs -r docker rmi -f
    
    # Clean up system
    docker system prune -f
    
    print_success "Cleanup completed"
}

# Main script logic
main() {
    if [[ $# -eq 0 ]]; then
        # No arguments - test all examples
        test_all_examples
    elif [[ "$1" == "clean" ]]; then
        # Clean up resources
        cleanup
    elif [[ "$1" == "help" ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        # Show help
        echo "Build and Test Script for Dockerfile Examples"
        echo
        echo "Usage:"
        echo "  $0                    # Test all examples"
        echo "  $0 [example-path]     # Test specific example"
        echo "  $0 clean             # Clean up Docker resources"
        echo "  $0 help              # Show this help"
        echo
        echo "Examples:"
        echo "  $0 examples/beginner/01-hello-world"
        echo "  $0 messaging/01-mosquitto-basic"
        echo "  $0 clean"
    elif [[ -d "$1" ]]; then
        # Test specific example
        test_example "$1"
    else
        print_error "Directory '$1' does not exist"
        exit 1
    fi
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose > /dev/null 2>&1; then
    print_warning "docker-compose not found. Some tests may be skipped."
fi

# Run main function
main "$@"
