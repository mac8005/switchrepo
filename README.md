# switchrepo - Getting Started
ohmyzsh Plugin to easy switch between Azure DevOps Repos

If Repository is already cloned switchrepo will switch to the repo dir, if Repository is not yet there it will be cloned first

## installation

### Download PlugIn
```
git clone https://github.com/mac8005/switchrepo.git $ZSH/custom/plugins/switchrepo
```

### Enable PlugIn

You'll need to enable the PlugIn in the `.zshrc` file. You'll find the zshrc file in your `$HOME` directory. Open it with your favorite text editor and you'll see a spot to list all the plugins you want to load.

```sh
vi ~/.zshrc
```

For example, this might begin to look like this:

```sh
plugins=(
  git
  bundler
  dotenv
  macos
  rake
  rbenv
  ruby
)
```

**Add switchrepo to the plugins list**

```sh
plugins=(
  git
  bundler
  dotenv
  macos
  rake
  rbenv
  ruby
  switchrepo
)
```

### Add required Environment Variables
`switchrepo` need these envs:

| Name    | Description                                                                                           |
| :-------- | :------------------------------------------------------------------------------------------------ |
| **SWITCHREPO_WORKROOT**  | Your local working direcotry where the Repositories should be stored |
| **SWITCHREPO_ORG**  | Azure DevOps Organisation. e.g. --> https://dev.azure.com/ORG   |
| **SWITCHREPO_PROJ** | Azure DevOps Project. e.g. --> https://dev.azure.com/ORG/PROJ  |
| **SWITCHREPO_PAT** | Personal Access Token which will be used to query Azure DevOps |

**To add the Vars to `~/.zshenv`**

```
echo 'export SWITCHREPO_WORKROOT=/Users/massimo/Git/' >> ~/.zshenv
echo 'export SWITCHREPO_ORG=myorg' >> ~/.zshenv
echo 'export SWITCHREPO_PROJ=myproject' >> ~/.zshenv
echo 'export SWITCHREPO_PAT=mysecret' >> ~/.zshenv
```

### Usage
`sr <searchstring>`

e.g. `sr uti`

![alt text](https://github.com/mac8005/switchrepo/blob/main/sample.png?raw=true)


