

default install creates the admin user(adminnate)

create daily user (natepm)


```bash
sudo add-apt-repository -y ppa:git-core/ppa;
sudo apt-get -y update;
sudo apt-get install -y \
curl \
git \
tree \
make \
wget \
zip \
unzip

```

```bash
git config --global init.defaultBranch main
git config --global user.email "npmarks@gmail.com"
git config --global user.name "Nate Marks"
```
clone ubuntu2404_dotfiles

make packages
make bin

configure git to ssh to github





Configure swappiness from default (60) to recommended (10)
https://help.ubuntu.com/community/SwapFaq#What_is_swappiness_and_how_do_I_change_it.3F




### Import and trust gpg keys
Export/create the private key files from 1Password and import them.  You need to use the command line to get properly prompted for the passphrase
```console
foo@bar:~$ gpg --import gpg-private-nmarks-imprivata-com.key 
foo@bar:~$ gpg --import gpg-private-npmarks-gmail-com.key 
foo@bar:~$ gpg --list-keys
/home/nmarks/.gnupg/pubring.kbx
-------------------------------
pub   ed25519 2022-01-29 [SC] [expires: 2024-01-29]
      E003CE06B8BEFE9A9D4DFC9DBF93336BFF040C0E
uid           [ unknown] Nathan Marks <nmarks@imprivata.com>
sub   cv25519 2022-01-29 [E] [expires: 2024-01-29]

pub   ed25519 2022-01-29 [SC] [expires: 2024-01-29]
      49F4D75E877FDC3CA1DB2CA0D6D259FDB87ACF43
uid           [ unknown] Nate Marks <npmarks@gmail.com>
sub   cv25519 2022-01-29 [E] [expires: 2024-01-29]


# restart the keying daemon to get the keys to show up in s\Ubuntu Seahorse (Passwords and Keys)
foo@bar:~$ gnome-keyring-daemon -r -d

foo@bar:~$ gpg --edit-key E003CE06B8BEFE9A9D4DFC9DBF93336BFF040C0E
gpg (GnuPG) 2.2.19; Copyright (C) 2019 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Secret key is available.

sec  ed25519/BF93336BFF040C0E
     created: 2022-01-29  expires: 2024-01-29  usage: SC  
     trust: unknown       validity: unknown
ssb  cv25519/1E3B8954E259F42D
     created: 2022-01-29  expires: 2024-01-29  usage: E   
[ unknown] (1). Nathan Marks <nmarks@imprivata.com>

gpg> trust
sec  ed25519/BF93336BFF040C0E
     created: 2022-01-29  expires: 2024-01-29  usage: SC  
     trust: unknown       validity: unknown
ssb  cv25519/1E3B8954E259F42D
     created: 2022-01-29  expires: 2024-01-29  usage: E   
[ unknown] (1). Nathan Marks <nmarks@imprivata.com>

Please decide how far you trust this user to correctly verify other users' keys
(by looking at passports, checking fingerprints from different sources, etc.)

  1 = I don't know or won't say
  2 = I do NOT trust
  3 = I trust marginally
  4 = I trust fully
  5 = I trust ultimately
  m = back to the main menu

Your decision? 5
Do you really want to set this key to ultimate trust? (y/N) y

```

```bash

```