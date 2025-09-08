#!/bin/bash

# Tamam Customer App Build Script
# Usage: ./scripts/build.sh [environment] [platform] [build_type]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Default values
ENVIRONMENT=${1:-development}
PLATFORM=${2:-android}
BUILD_TYPE=${3:-debug}

# Build configuration
BUILD_DIR="build"
OUTPUT_DIR="releases"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create output directory
mkdir -p "$OUTPUT_DIR"

print_status "Building Tamam Customer App"
print_status "Environment: $ENVIRONMENT"
print_status "Platform: $PLATFORM"
print_status "Build Type: $BUILD_TYPE"

# Validate environment
case "$ENVIRONMENT" in
    "development"|"staging"|"production")
        ;;
    *)
        print_error "Invalid environment: $ENVIRONMENT"
        echo "Valid environments: development, staging, production"
        exit 1
        ;;
esac

# Validate platform
case "$PLATFORM" in
    "android"|"ios"|"web"|"all")
        ;;
    *)
        print_error "Invalid platform: $PLATFORM"
        echo "Valid platforms: android, ios, web, all"
        exit 1
        ;;
esac

# Validate build type
case "$BUILD_TYPE" in
    "debug"|"release"|"profile")
        ;;
    *)
        print_error "Invalid build type: $BUILD_TYPE"
        echo "Valid build types: debug, release, profile"
        exit 1
        ;;
esac

# Set environment variables
export ENVIRONMENT="$ENVIRONMENT"
export BUILD_TYPE="$BUILD_TYPE"
export FLAVOR="$ENVIRONMENT"
export BUILD_DATE=$(date '+%Y-%m-%d')
export BUILD_NUMBER="${BUILD_NUMBER:-$(git rev-list --count HEAD 2>/dev/null || echo 1)}"
export GIT_COMMIT="${GIT_COMMIT:-$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')}"
export GIT_BRANCH="${GIT_BRANCH:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'unknown')}"

print_status "Build number: $BUILD_NUMBER"
print_status "Git commit: $GIT_COMMIT"
print_status "Git branch: $GIT_BRANCH"

# Update app constants based on environment
update_app_constants() {
    local env=$1
    local config_file="lib/util/app_constants.dart"
    
    print_status "Updating app constants for $env environment"
    
    case "$env" in
        "production")
            sed -i.bak "s|static const String baseUrl = '.*';|static const String baseUrl = 'https://admin.tamam.shop';|" "$config_file"
            ;;
        "staging")
            sed -i.bak "s|static const String baseUrl = '.*';|static const String baseUrl = 'https://staging.tamam.shop';|" "$config_file"
            ;;
        "development")
            sed -i.bak "s|static const String baseUrl = '.*';|static const String baseUrl = 'http://localhost:8000';|" "$config_file"
            ;;
    esac
}

# Clean previous builds
clean_build() {
    print_status "Cleaning previous builds..."
    flutter clean
    flutter pub get
}

# Build Android
build_android() {
    local build_type=$1
    
    print_status "Building Android app ($build_type)..."
    
    local dart_defines=(
        "--dart-define=ENVIRONMENT=$ENVIRONMENT"
        "--dart-define=BUILD_TYPE=$BUILD_TYPE"
        "--dart-define=FLAVOR=$FLAVOR"
        "--dart-define=BUILD_DATE=$BUILD_DATE"
        "--dart-define=BUILD_NUMBER=$BUILD_NUMBER"
        "--dart-define=GIT_COMMIT=$GIT_COMMIT"
        "--dart-define=GIT_BRANCH=$GIT_BRANCH"
    )
    
    if [ "$build_type" = "release" ]; then
        # Release build
        flutter build apk "${dart_defines[@]}" --release --obfuscate --split-debug-info=symbols/
        flutter build appbundle "${dart_defines[@]}" --release --obfuscate --split-debug-info=symbols/
        
        # Copy release files
        cp build/app/outputs/flutter-apk/app-release.apk "$OUTPUT_DIR/tamam-customer-${ENVIRONMENT}-${TIMESTAMP}.apk"
        cp build/app/outputs/bundle/release/app-release.aab "$OUTPUT_DIR/tamam-customer-${ENVIRONMENT}-${TIMESTAMP}.aab"
        
        print_success "Android release build completed"
        print_status "APK: $OUTPUT_DIR/tamam-customer-${ENVIRONMENT}-${TIMESTAMP}.apk"
        print_status "AAB: $OUTPUT_DIR/tamam-customer-${ENVIRONMENT}-${TIMESTAMP}.aab"
    else
        # Debug build
        flutter build apk "${dart_defines[@]}" --debug
        
        # Copy debug file
        cp build/app/outputs/flutter-apk/app-debug.apk "$OUTPUT_DIR/tamam-customer-${ENVIRONMENT}-debug-${TIMESTAMP}.apk"
        
        print_success "Android debug build completed"
        print_status "APK: $OUTPUT_DIR/tamam-customer-${ENVIRONMENT}-debug-${TIMESTAMP}.apk"
    fi
}

# Build iOS
build_ios() {
    local build_type=$1
    
    if [ "$(uname)" != "Darwin" ]; then
        print_warning "iOS builds are only supported on macOS"
        return
    fi
    
    print_status "Building iOS app ($build_type)..."
    
    local dart_defines=(
        "--dart-define=ENVIRONMENT=$ENVIRONMENT"
        "--dart-define=BUILD_TYPE=$BUILD_TYPE"
        "--dart-define=FLAVOR=$FLAVOR"
        "--dart-define=BUILD_DATE=$BUILD_DATE"
        "--dart-define=BUILD_NUMBER=$BUILD_NUMBER"
        "--dart-define=GIT_COMMIT=$GIT_COMMIT"
        "--dart-define=GIT_BRANCH=$GIT_BRANCH"
    )
    
    if [ "$build_type" = "release" ]; then
        flutter build ios "${dart_defines[@]}" --release --no-codesign
        print_success "iOS release build completed (archive in Xcode for distribution)"
    else
        flutter build ios "${dart_defines[@]}" --debug --no-codesign
        print_success "iOS debug build completed"
    fi
}

# Build Web
build_web() {
    local build_type=$1
    
    print_status "Building Web app ($build_type)..."
    
    local dart_defines=(
        "--dart-define=ENVIRONMENT=$ENVIRONMENT"
        "--dart-define=BUILD_TYPE=$BUILD_TYPE"
        "--dart-define=FLAVOR=$FLAVOR"
        "--dart-define=BUILD_DATE=$BUILD_DATE"
        "--dart-define=BUILD_NUMBER=$BUILD_NUMBER"
        "--dart-define=GIT_COMMIT=$GIT_COMMIT"
        "--dart-define=GIT_BRANCH=$GIT_BRANCH"
    )
    
    if [ "$build_type" = "release" ]; then
        flutter build web "${dart_defines[@]}" --release --web-renderer canvaskit
    else
        flutter build web "${dart_defines[@]}" --debug
    fi
    
    # Create web archive
    cd build/web
    tar -czf "../../$OUTPUT_DIR/tamam-customer-web-${ENVIRONMENT}-${TIMESTAMP}.tar.gz" .
    cd ../..
    
    print_success "Web build completed"
    print_status "Archive: $OUTPUT_DIR/tamam-customer-web-${ENVIRONMENT}-${TIMESTAMP}.tar.gz"
}

# Run tests before building (for release builds)
run_tests() {
    if [ "$BUILD_TYPE" = "release" ]; then
        print_status "Running tests before release build..."
        
        if flutter test; then
            print_success "All tests passed"
        else
            print_error "Tests failed. Aborting release build."
            exit 1
        fi
    fi
}

# Analyze code quality
analyze_code() {
    print_status "Analyzing code quality..."
    
    if flutter analyze; then
        print_success "Code analysis passed"
    else
        print_warning "Code analysis found issues. Review before releasing."
        if [ "$BUILD_TYPE" = "release" ]; then
            read -p "Continue with release build? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_status "Build cancelled by user"
                exit 0
            fi
        fi
    fi
}

# Generate build report
generate_build_report() {
    local report_file="$OUTPUT_DIR/build-report-${TIMESTAMP}.md"
    
    cat > "$report_file" << EOF
# Tamam Customer App Build Report

**Date**: $(date)
**Environment**: $ENVIRONMENT
**Platform**: $PLATFORM
**Build Type**: $BUILD_TYPE
**Build Number**: $BUILD_NUMBER
**Git Commit**: $GIT_COMMIT
**Git Branch**: $GIT_BRANCH

## Build Configuration

- **App Name**: $(grep -r "appName" lib/util/build_config.dart | head -1)
- **Package Name**: $(grep -r "packageName" lib/util/build_config.dart | head -1)
- **Base URL**: $(grep -r "baseUrl" lib/util/app_constants.dart | head -1)

## Build Artifacts

EOF

    # Add artifact information
    if [ "$PLATFORM" = "android" ] || [ "$PLATFORM" = "all" ]; then
        echo "### Android" >> "$report_file"
        ls -la "$OUTPUT_DIR"/*android*.apk 2>/dev/null | tail -1 >> "$report_file" || true
        ls -la "$OUTPUT_DIR"/*android*.aab 2>/dev/null | tail -1 >> "$report_file" || true
        echo "" >> "$report_file"
    fi
    
    if [ "$PLATFORM" = "web" ] || [ "$PLATFORM" = "all" ]; then
        echo "### Web" >> "$report_file"
        ls -la "$OUTPUT_DIR"/*web*.tar.gz 2>/dev/null | tail -1 >> "$report_file" || true
        echo "" >> "$report_file"
    fi
    
    cat >> "$report_file" << EOF

## Flutter Information

\`\`\`
$(flutter --version)
\`\`\`

## Dependencies

\`\`\`
$(flutter pub deps --style=compact)
\`\`\`

---
Generated by Tamam Build Script
EOF

    print_success "Build report generated: $report_file"
}

# Main build process
main() {
    print_status "Starting build process..."
    
    # Update app constants
    update_app_constants "$ENVIRONMENT"
    
    # Clean and prepare
    clean_build
    
    # Code quality checks
    analyze_code
    
    # Run tests for release builds
    run_tests
    
    # Build based on platform
    case "$PLATFORM" in
        "android")
            build_android "$BUILD_TYPE"
            ;;
        "ios")
            build_ios "$BUILD_TYPE"
            ;;
        "web")
            build_web "$BUILD_TYPE"
            ;;
        "all")
            build_android "$BUILD_TYPE"
            build_ios "$BUILD_TYPE"
            build_web "$BUILD_TYPE"
            ;;
    esac
    
    # Generate build report
    generate_build_report
    
    print_success "Build process completed successfully!"
    print_status "Build artifacts are available in the $OUTPUT_DIR directory"
    
    # Restore original app constants
    if [ -f "lib/util/app_constants.dart.bak" ]; then
        mv "lib/util/app_constants.dart.bak" "lib/util/app_constants.dart"
    fi
}

# Run main function
main