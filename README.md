# WordBase Installation Script

Scripts I use to get me up and running with a new, local development WordPress install ASAP. It's a bit messy and definitely not refined but it does what I want it to do right now and gets me up and running quickly.

What it gets me...
- new WordPress install
- new starter theme ([Roots.io Sage](roots.io/sage/))
- new theme clean-up extension ([Roots.io Soil](roots.io/plugins/soil/))
- configured `wp_config.php`
- configured database
- downloaded requirements
- compiled assets
- BitBucket repository

# Getting Started

## 1. Prerequisities

This is where it gets pretty dirty. I really just haven't had time to clean this up, so this is what I'm running right now.

### Bash profile setup

BitBucket commands deserve better than this, but I add this to my `.bash_profile`...

```
# Bitbucket Functions
bitbucket_create() { curl -X POST --user [USER EMAIL HERE]:[PASSWORD HERE] https://api.bitbucket.org/2.0/repositories/[USERNAME HERE]/$1 --data "is_private=true" ;}
bitbucket_delete() { curl -X DELETE --user [USER EMAIL HERE]:[PASSWORD HERE] https://api.bitbucket.org/2.0/repositories/[USERNAME HERE]/$1 ;}
bitbucket_init() { mkdir $1; cd $1; bitbucket_create $1; git init; git remote add origin git@bitbucket.org:[USERNAME HERE]/$1.git ;}
bitbucket_clone() { git clone git@bitbucket.org:[USERNAME HERE]/$1.git ;}
```

Script alias...

```
# WP stuff
alias wp_init="~/scripts/wordbase-script/wp-init.sh"
```

## 2. Go at it...

For me, I make sure MAMP is running before running this but it should work fine as long as you have your MySQL instance running.

```
wp_init project-name
```

Or, if you want the Roots theme....

```
wp_init -r project-name
```

That's it.

If your database fails to create - if you forgot to start your MySQL instance or created a database with an existing name or something - you can run...

```
wp_init -d database-name
```

To create the database. Or you can just run that to create databases. Woohoo.

## 3. Options

o

These run alongside the entire install script...
- `-s` - install Sage theme with install (or `-r`)
- `-v` - verbosity

If you want to run any part of that script independantly there are flags to run each part by itself...
- `-d` - create the database
- `-b` - create the BitBucket repo
- `-w` - install WordPress
- `-c` - configure `wp-config.php`
- `-t` - install the Sage theme
- `-o` - install Soil extension

# TODO

- Automate setting up Sage Theme:
	- change Sage title
	- activate Sage
