ASP.NET vNext Environment Installer
===================================

> Copyright (c) 2014 Erlimar Silva Campos, E5R Team

Scripts de instalação do ambiente ASP.NET vNext para time de desenvolvimento E5R.

#### [Notas de lançamento](https://github.com/erlimar/E5RInstallvNext/releases)

#### Faz o download e instala de uma única vez

  * KRuntime 1.0.0-alpha4 x86
  * KRuntime 1.0.0-alpha4 x86 [core]
  * KRuntime 1.0.0-alpha4 x64
  * KRuntime 1.0.0-alpha4 x64 [core]
  * NuGet.exe

Caso já existam versões do KRE instaladas, as listadas acima serão incluídas como
uma atualização (se não existirem) e os seguintes aliases serão criados:

  * `e5r` Atalho para `e5r-x86`
  * `e5r-core` Atalho para `e5r-x86-core`
  * `e5r-x86` .NET Framework 32 bits
  * `e5r-x86-core` .NET Core Framework 32 bits
  * `e5r-x64` .NET Framework 64 bits
  * `e5r-x64-core` .NET Core Framework 64 bits

Com esses atalhos fica mais intuitivo escolher o ambiente de desenvolvimento.

```
kvm use e5r
```

#### Deixa acessíveis todos os comandos da plataforma

  * `kvm`
  * `kpm`
  * `klr`
  * `k`
  * `nuget`

# Instruções de instalação

### Windows

1. Baixe os scripts `E5R-InstallvNext.ps1` e `E5R-InstallvNext-Windows.cmd`
2. Execute `E5R-InstallvNext-Windows.cmd`

### Unix

Em breve...

# Pré-requisitos

Você precisa de privilégios de `Administrador` ou `root` e uma conexão ativa com a Internet.
