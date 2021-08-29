# Creating & Running A Custom NGINX Image

This repository contains code to build an NGINX Open Source container with a custom `index.html` web page.  Most of the examples I could find online were either using the default homepage or a simple Hello-World type container, but didn't go into the basics beyond this.  The goal is to simply show how to build a container, add custom content and change the port NGINX runs on.

## Modify The Default Page

I wanted to modify the default NGINX page `index.html` and I created a directory named `site-content` to host the files. I added `Jedi.png` to the folder, then made a few tweaks to the html code.

```html
<!DOCTYPE html>
<html>

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
    <title>The DevOps Jedi</title>
    <style>
        body {
            width: 35em;
            margin: 0 auto;
            font-family: Tahoma, Verdana, Arial, sans-serif;
        }
    </style>
</head>

<body>
    <h1>Welcome To V0.1!</h1>
    <img src="Jedi.png" alt="The force is strong in this one" class="center">
    <p>If you see this page, the devopsings have been strong as this has been deployed via a custom Docker image.</p>

    <p>For more cloud solutions please refer to
        <a href="https://github.com/thedevopsjedi">my GitHub Repos</a>.<br>
    </p>

    <p><em>Thank you for using the interwebs responsibly.</em></p>


</body>

</html>
```

### Test The HTML Web Page

I opened the custom `index.html` locally and it loaded fine, but I wanted to check that it worked correctly before trying to create a custom NGINX container of my own.  I found that the command below would pull down the `nginx:latest` image and mount custom content within the container.

```docker
docker run -it --rm -d -p 80:80 --name web -v ${pwd}/site-content:/usr/share/nginx/html nginx:latest
```

### Docker Command Syntax
The docker command is used as follows:
`docker run [OPTIONS] IMAGE [COMMAND] [ARG...]`

Let me explain this in a little more detail:

| Option | Description |
|:--:|:--|
| ` -it ` | Instructs Docker to allocate a pseudo-TTY connected to the container’s stdin; creating an interactive bash shell in the container. |
| ` --rm ` | Automatically removes the container when it exits, or is stopped. |
| ` -d ` | Runs the container in the background and prints the container ID. If this isn't specified the output from the container is written to the console and `Ctrl+C` is required to exit the container. |
| ` -p ` | Publishes a containers port(s) to the host. This controls the mapping between the container and the host running it. |
| ` --name ` | If you don't specify a name, the docker daemon generates a random string name. |
| ` -v ` | Mounts a local folder as a volume inside the container. Using `${pwd}` allows the path to be relative to where the command is being run from. |

The image is specified using a tag that is applied to the image stored in the docker registry.  In the example above this is in the format of `nginx:latest` where `nginx` represents the repository, and `latest` represents the version of the image to run.  

It is considered good practice to tag the most recent stable image with both a version number and latest.  When no tag is specified, latest will be used.

### Stopping The Container

As the container runs in the background a command is required to stop it:

`docker stop web`

## Creating A Custom Image

Because I want to change elements of the NGINX deployment, I will need to build a custom image.  There are 2 parts to this process:  

1. Creating an NGINX `default.conf` file that will replace the out of the box config and allows us to add custom content and change the port NGINX is listening on.
2. Creating a `Dockerfile` that will build the image to meet our requirements.  

#### default.conf

```nginx
server {
    listen              4000;
    root                /usr/share/nginx/html/;
    index               index.html;
}
```

The `default.conf` file is very simple:  

1. Sets the port the server is listening on to `4000`
2. Sets the root content folder to `/usr/share/nginx/html/`
3. Sets the default page to `index.html`

#### Dockerfile

```dockerfile
FROM nginx:1.21.1-alpine
COPY ./site-content /usr/share/nginx/html
COPY ./default.conf /etc/nginx/conf.d/default.conf
EXPOSE 4000/tcp
```

The `Dockerfile` is also relatively simple:  

1. Uses the `nginx:1.21.1-alpine` as its base image for the build
2. Copies the contents of the `site-content` folder into `/usr/share/nginx/html`
3. Replaces the `default.conf` file in `/etc/nginx/conf.d` with our version
4. Informs docker the container listens on TCP port 4000 at runtime

###

### Build & Tag The Custom Image

#### Checking The Folder Structure

In preparation for the build I ran the `tree` command to ensure everything was in the correct path:

```bash
.
├── Dockerfile
├── README.md
├── default.conf
└── site-content
    ├── Jedi.png
    └── index.html
```

#### Running The Build

`docker build -t thedevopsjedi/web:v0.1 .`

NOTE: To set multiple tags on the same image:

`docker build -t thedevopsjedi/web:v0.1 -t thedevopsjedi/web:latest .`

## Run The Custom Image

The command below will run the custom image as a container locally:  

`docker run -it --rm -d -p 80:4000 --name webv0.1 thedevopsjedi/web:v0.1`

Open [http://localhost](http://localhost) using your browser to verify the container is running successfully.

## Stop The Custom Container

To stop the container:

`docker stop webv0.1` or `docker stop ee5457943e2a`

## Delete The Custom Image
docker image rm --force thedevopsjedi/web:v0.1

## Other Useful Commands

### List All Running Containers

To list all running containers, the `docker ps` command can be used.  

Example Output:  

| CONTAINER ID | IMAGE                  | COMMAND                | CREATED       | STATUS       | PORTS                                         | NAMES   |
| :----------- | :--------------------- | :--------------------- | :------------ | :----------- | :-------------------------------------------- | :----   |
| ee5457943e2a | thedevopsjedi/web:v0.1 | "nginx -g 'daemon of…" | 7 seconds ago | Up 6 seconds | 80/tcp, 0.0.0.0:80->4000/tcp, :::80->4000/tcp | webv0.1 |

Both the Container ID or the Name can then be used for other docker commands.  

### Access The CLI Inside A Running Container

To access the CLI inside a container use the `docker exec` command:

`docker exec -it ee5457943e2a /bin/sh` or `docker exec -it webv0.1 /bin/sh`

You could then see all open ports:

`netstat -tulpn | grep LISTEN`

You could also confirm the Linux version inside the container:  

`cat /etc/os-release`  

Example Output:  

```bash
NAME="Alpine Linux"
ID=alpine
VERSION_ID=3.14.1
PRETTY_NAME="Alpine Linux v3.14"
HOME_URL="https://alpinelinux.org/"
BUG_REPORT_URL="https://bugs.alpinelinux.org/"
```
