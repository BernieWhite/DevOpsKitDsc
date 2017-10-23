# Development instructions

## Building the project manually

```powershell
# Restore packages
dotnet restore ./src/DevOpsKitDsc

# Build the library
dotnet publish -f net451 ./src/DevOpsKitDsc
dotnet publish -f netstandard1.6 ./src/DevOpsKitDsc
```