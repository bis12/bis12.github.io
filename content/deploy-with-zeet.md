+++
title = "Deploying this site with Zeet"
date = 2022-10-26
+++

This site has been around for quite a while now (obviously without very many updates). In fact, the last update was long enough ago that I didn't remember how to deploy it anymore.
It had involved some complicated [Taskcluster](https://taskcluster.net) tasks that manually pushed things to s3 and such but it's been quite a while. In addition, it used Jekyll and
I don't even have ruby installed on this machine at this point, nor did I feel like installing it just to hack on this. 

> It was time for a refresh.

I decided to port the static generation to [Zola](https://www.getzola.org) for no real reason other than that it looked nice. For hosting purposes, I wanted to try out something new so I am trying out
[Zeet](https://zeet.co). It is definitely feels a bit overpowered for deploying a single static site but who knows, maybe I'll build some more interesting bits into this eventually.
Plus, it was time to get to know my old friend Kubernetes again after getting back from [boat school](https://www.nwswb.edu) and what better way than to use Zeet's expertise in setting
up a correct deployment. It is interesting here because Zeet is just managing resources in your own cloud account, none of your services are actually running in Zeet itself.

{{ figure(id="zeet-fig1", path="zeet-screenshot.png") }}

Zeet is interesting because it is opinionated on the basics of how one would set up a deployment like this but extremely flexible after that. It looks to grow with you as your needs change and grow over time. This should hopefully avoid the dreaded feeling of being stuck in a Heroku deployment when you know you will need to move out of it soon to keep scaling or get some feature you can't achieve in their walls.

## Zola-ification

This part was easy enough once I actually sat down and decided to do it. Ultimately the models of Zola and Jekyll are similar enough that 90% of the work is just cp-ing files around to new locations and updating a few things. It wouldn't be too hard to automate most of it if you had to move a large site but for me with my pitifully few posts, I just changed things manually. There are a few batteries included with Zola that made my life even easier as I could just dump some of the more complex pieces of my old setup (code highlighting, etc). The one thing I couldn't achieve in the time I set out for myself was to be able to inline css/js resources. This is something I had done on my blog a long time ago for the fun of trying to get pageload times as low as I could (obviously not really necessary in this context). So, with that in mind, now we just load them in with tags the old way. Ultimately this is probably nicer anyway.

With that complete and running locally, it was time to get it into a Docker image for deploying with Zeet.

## A wrong turn

There are roughly two ways to deploy an app with Zeet -- Serverless and Kubernetes. I had never really used AWS Lambda before (which is what Zeet is configuring for me here) so I figured I would give it a try. I know it is a poor choice for a static site, but I figured I could hack it into working and learn something in the process. After a couple hours of poking around, I'm certain that you _could_ make this sort of deployment work but it really is more work than you'd want and for no benefit. I did learn something at least. It's a neat tool and I could definitely see reaching for it later in a more appropriate scenario.

## Back to Kubernetes

After I gave up with Serverless, I went back to my old friend Kubernetes. Zeet can set up and manage an EKS cluster for you and after deciding it was worth a few dollars to try this out (a running cluster costs whereas the Lambda functions are practically free for me unless somehow billions of people suddenly want to read my blog). All that was involved was clicking a few buttons, and a few minutes later I had a cluster up and running, ready for my image. The image itself is pretty straightforward.

```dockerfile
FROM nginx:1.23.2-alpine

RUN apk add zola

ENV build /build

RUN mkdir $build
WORKDIR $build

COPY . .
RUN zola build
RUN mv ./public/* /usr/share/nginx/html

```

This probably isn't the optimal way of doing this but it is good enough for now! After the obvious faffing about that is always involved in getting ports and healthchecks to all line up correctly, I was rewarded with the page you're viewing currently. 

Now all that was left to do was to write a new post about this experience and publish it here!

> Fin.

{{ figure(id="zeet-fig2", path="zeet-post.png") }}
