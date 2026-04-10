# Aplicativo Horus de Denúncias

Aplicativo mobile Android desenvolvido em Flutter.  
Permite cadastrar, listar, editar e excluir denúncias com foto e localização via GPS.

---

## Funcionalidades

- Cadastro e autenticação de usuários (login/cadastro)
- Localização via GPS com conversão de coordenadas em endereço
- Foto opcional anexada à denúncia
- Controle de acesso: apenas o criador pode editar ou excluir suas denúncias
- Visualização de denúncias de outros usuários em modo somente leitura

---

## Estrutura do projeto

```
lib/
├── main.dart
├── models/
│   ├── denuncia.dart
│   └── usuario.dart
├── database/
│   ├── denuncia_dao.dart
│   └── usuario_dao.dart
└── screens/
    ├── login_screen.dart
    ├── cadastro_screen.dart
    ├── lista_denuncias_screen.dart
    ├── form_denuncia_screen.dart
    └── detalhe_denuncia_screen.dart
```

---

## Dependências

Adicione em `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.3
  path: ^1.9.0
  image_picker: ^1.1.2
  geolocator: ^13.0.2
  geocoding: ^3.0.0
```

| Pacote | Uso |
|---|---|
| `sqflite` | Banco de dados SQLite local |
| `path` | Resolução de caminho do banco |
| `image_picker` | Seleção de foto da galeria |
| `geolocator` | Obtenção de coordenadas GPS |
| `geocoding` | Conversão de coordenadas em endereço |

---

## Permissões para o Android

Em `android/app/src/main/AndroidManifest.xml`, antes de `<application>`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

---


## Banco de dados

O app utiliza dois bancos SQLite separados:

**usuarios.db**

| Campo | Tipo | Descrição |
|------|------|-----------|
| id | INTEGER (PK) | Identificador único |
| email | TEXT (UNIQUE) | E-mail do usuário |
| senha | TEXT | Senha do usuário |

**denuncias.db**

| Campo | Tipo | Descrição |
|------|------|-----------|
| id | INTEGER (PK) | Identificador único |
| nome | TEXT | Nome da denúncia |
| localizacao | TEXT | Endereço ou coordenadas |
| foto | TEXT | Caminho da imagem (opcional) |
| usuario_id | INTEGER | ID do usuário criador |
---

## Fluxo de navegação

```
Login
  ├── (sem conta?) → Cadastro → volta ao Login
  └── (login bem-sucedido) → Lista de Denúncias
        ├── (denúncia própria) → Editar / Excluir
        ├── (denúncia de outro usuário) → Ver Detalhes
        ├── (botão +) → Nova Denúncia
        └── (botão Sair) → Login
```

---

## Validações

**Login / Cadastro**
- E-mail com formato válido
- Senha com mínimo de 6 caracteres
- Confirmação de senha idêntica à senha
- E-mail único no cadastro

**Formulário de denúncia**
- Nome obrigatório
- Localização obrigatória (digitada ou via GPS)
- Foto opcional

---

## Localização via GPS

Ao tocar no botão de localização ao lado do campo **Localização** no formulário:

1. Verifica se o GPS está ativo no dispositivo
2. Solicita permissão de localização ao usuário
3. Obtém as coordenadas atuais
4. Tenta converter em endereço legível (rua, bairro, cidade)
5. Se sem internet, salva as coordenadas brutas (`-26.22345, -52.67891`)

---

## Controle de acesso por usuário

| Situação | Ações disponíveis |
|---|---|
| Denúncia criada pelo usuário logado | ✏️ Editar — 🗑️ Excluir |
| Denúncia criada por outro usuário | 👁️ Ver detalhes |

---
