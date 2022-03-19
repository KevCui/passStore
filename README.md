# passStore

> A command-line password store on your local machine

## Table of Contents

- [Why](#why)
- [Preparation](#preparation)
  - [1. Generate a symmetric key](#1-generate-a-symmetric-key)
  - [2. Export global variable PASSSTORE_KEY](#2-export-global-variable-passstore_key)
- [Usage](#usage)
  - [Example](#example)
    - [Add a new credential](#add-a-new-credential)
    - [Select a specific password](#select-a-specific-password)
    - [Reveal the selected username](#reveal-the-selected-username)
    - [Reveal the selected password](#reveal-the-selected-password)

## Why

I need a simple command-line password manager which can store the credentials locally. However, the majority of password managers are cloud based. Some of them do store credentials locally, like KeePass, but they are overkill for my needs...

## Preparation

### 1. Generate a symmetric key

```
$ openssl rand 128 > ~/.ssh/passStore.key

```

### 2. Export global variable PASSSTORE_KEY

```
$ export PASSSTORE_KEY=~/.ssh/passstore.key
```

It's recommended to add this command line above into your `.bashrc` or `.zshrc` or other shell rc file.

## Usage

```
Usage:
  ./passStore.sh [-a] [-u] [-p] [-h|--help]

Options:
  -a                      add new credential
  -u                      display selected username
  -p                      display selected password
  -h | --help             display this help message
```

### Example

#### Add a new credential

```bash
$ ./passStore.sh -a
Site: test site
Username: test@test.com
Password:
```

The credential will be added to `./.credential.list` file as a new line, for example:

```
test site❚test@test.com❚U2FsdGVkX18gTcawHWrePMBnPpLSw+CRRdvacJPOb1JMl4N1Sn8asXK06GPtWiDC
```

#### Select a specific password

```bash
$ ./passStore.sh
<use fzf to search for the site and username>
```

#### Reveal the selected username

```bash
$ ./passStore.sh -u
test@test.com
```

#### Reveal the selected password

```bash
$ ./passStore.sh -p
thisisatestpassword
```

---

<a href="https://www.buymeacoffee.com/kevcui" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-orange.png" alt="Buy Me A Coffee" height="60px" width="217px"></a>