# sf6
Sf6 2le project template

To bootstrap a project use the following steps:

```bash
composer create-project 2lenet/sf6 project_name

cd project_name
make init
make install
make start
```

This will create your project, modify all reference to [PROJECT] in config files

After that you have : 

* sf6 project
* sonarqube configuration
* docker and dockercompose config
* ci with test, build and deploy
