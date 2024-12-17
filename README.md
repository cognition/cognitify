# Cognitify

## Linux Configuration and Customisation





## How to Install

```bash
sudo cp -r bash.bashrc.d /etc/ 
sudo groupadd cognitify 
sudo usermod -aG cognitify $SUDO_USER
sudo chgrp -R cognitify /etc/bash.bashrc.d
sudo chmod -R g+w /etc/bash.bashrc.d 
sudo cp completions/* /etc/bash_completions.d/
```

```
cp home-files/bash_logout ~/.bash_logout 



```



### Root User

To remove the ```_YOU_ARE_ROOT_ ``` message:

```bash
sudo touch /root/.no_root_message 
```




## Maintained

Ramon Brooker <rbrooker@aeo3.io> 
(C) 2024
