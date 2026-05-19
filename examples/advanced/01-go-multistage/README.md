# Go Multi-Stage Build Example

This example demonstrates an **extreme** multi-stage build using Go, resulting in a final image built from `scratch` (absolutely minimal).

## 🎯 What You'll Learn

- Building Go applications in Docker
- Using `scratch` as a base image
- Creating ultra-small Docker images (< 10MB)
- Static compilation with Go
- CGO disabled builds

## 📊 Image Size Comparison

| <sub>Build Type</sub> | <sub>Image Size</sub> | <sub>Description</sub> |
|-----------|-----------|-------------|
| <sub>Single-stage (golang:1.21)</sub> | <sub>~800MB</sub> | <sub>Includes entire Go toolchain</sub> |
| <sub>Multi-stage (alpine)</sub> | <sub>~15MB</sub> | <sub>Uses Alpine Linux runtime</sub> |
| <sub>Multi-stage (scratch)</sub> | <sub>**~6MB**</sub> | <sub>Only contains the binary</sub> |

## 🚀 Quick Start

Build and run:
```bash
docker build -t go-multistage .
docker run -p 8080:8080 go-multistage
```

Test:
```bash
curl http://localhost:8080
curl http://localhost:8080/health
```

## 🔍 Key Features

### Scratch Base Image
The `scratch` image is Docker's most minimal base - it's literally empty. Perfect for Go binaries that are statically compiled.

### Static Compilation
```dockerfile
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags="-w -s" -o server .
```

- `CGO_ENABLED=0` - Disable CGO for static linking
- `-ldflags="-w -s"` - Strip debug info and symbol table
- `-a` - Force rebuilding of packages

## 📈 Benefits

- ✅ **Extremely small** - Only ~6MB
- ✅ **Highly secure** - Minimal attack surface
- ✅ **Fast transfers** - Quick pull/push times
- ✅ **No runtime dependencies** - Self-contained binary

## ⚠️ Limitations

- No shell access (can't use `docker exec`)
- No package manager
- No CA certificates (need to copy if making HTTPS calls)
- Debugging is more challenging

## 🔧 Adding CA Certificates

If your app makes HTTPS calls, add this to the Dockerfile:

```dockerfile
FROM alpine:latest AS certs
RUN apk --update add ca-certificates

FROM scratch
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /build/server /server
```

## 📚 Learn More

- [Go Documentation](https://golang.org/doc/)
- [Docker Multi-Stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Scratch Base Image](https://hub.docker.com/_/scratch)