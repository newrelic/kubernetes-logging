# Development

So you want to do development one of these here config files! 
These instructions are for development on **MacOS**.

## Summary

Here's a summary of what you'll frequently need to do in this repo. More details in sections below.
* Update the version of the Docker image used when a new version is ready (note that the version number is in two places, see below)
* After you merge to master in this repo, you'll need to copy changes to the k8s-config-generator repo

## Getting started

We'll use [minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/) as our local test environment. 

## Important note about Virtualbox and Minikube versions

*IMPORTANT NOTE*: We have seen problems with Virtualbox and Minikube that were not installed with `brew cask`. 
What ends up happening is that `minikube start` hangs on `Waiting for: apiserver`. If you see that, we think the issue
 is that you have a Virtualbox or Minikube that is the wrong version (or maybe not configured as you get it from 
 Homebrew). The way we've seen this work is to let Homebrew install both of these. 
 
So, check to make sure you have the Homebrew-installed versions of Virtualbox and Minikube.
* Do a `brew cask list --versions` and see if it lists `virtualbox` version >= `6.0.10` and 
 `minikube` >= `1.3.1`
* If it does, great
* If it doesn't, uninstall whichever apps were installed manually, then have Homebrew install them (see instructions
  in the next section)
  * Note that you will need to kill the Virtualbox app and drag the Virtualbox application to the Trash
* If you have brew-installed versions of the apps, but they are older versions, have brew update them

See below for more installation instructions
  
### Initial install

* Install Virtualbox: `brew cask install virtualbox`
* Install minikube: `brew cask install minikube`
* Install Helm: `brew install kubernetes-helm`

### Get minikube started

* Start minikube: `minikube start`
* Install Tiller onto the minikube cluster: `helm init`
   * Tiller is a pod that gets deployed into your cluster that allows the `helm` executable to talk to your cluster

### Deploy test application

* Start the minikube dashboard (so you can see all your k8s objects in one spot): `minikube dashboard`
* Download and start the `hello-minikube` deployment: `kubectl run hello-minikube --image=k8s.gcr.io/echoserver:1.10 --port=8080`
* Expose the deployment on a known port: `kubectl expose deployment hello-minikube --type=NodePort`

## Making changes

* To get a new version of the newrelic-fluentbit-output container, update the version tag of the `image` 
  field in:
  * [new-relic-fluent-plugin.yml]
  * [helm/newrelic-logging/values.yaml]
* Make any other changes you need to the `.yml` files

## Testing

* Clean up anything you had running in minikube before
  * If you deployed this as a Helm chart: `helm delete (release-name)`. Helm gives you a unique release name every time
    you deploy a chart. It looks like "(unusual-adjective)-(animal-noun)", like `bumptious-seagull`
  * If you deployed the manifests manually:
    * If you just want to replace the DaemonSet: `kubectl delete ds/newrelic-logging`
      * You will almost always just need to do this
    * If you want to completely blow everything away: `minikube delete && minikube start`, then follow the 
    instructions above in the "Deploy test application" section
      * You'll only need to do this if something is really wonky and you can't figure out what's wrong
* Deploy the logging objects (there's two ways to do this, so two things you need to test): 
  * Deploy Helm chart: `helm install --set licenseKey=(your-license-key) ./helm/newrelic-logging/`
  * Manually deploy manifests: `kubectl apply -f .` (from this repo's root directory)
* Get the URL of the `hello-minikube` service: `minikube service hello-minikube --url`
* Hit that URL in your browser (or use `curl`) in order to get it to log something
  * Add a unique-ish string as a path to the URL. The full URL will logged in the message, so it gives you something
    to search for in the Logging product
  * So if the URL you got from the minikube command was `http://192.168.99.104:31777`, curl something
    like `http://192.168.99.104:31777/SomeStringSpecificToYou`.
* You can see what the test application is logging in the minikube dashboard web page, or by running
  `kubectl logs $(kubectl get pods | grep hello-minikube | awk '{print $1}')`
* Go look in the logging product for your log lines (perhaps by searching for the unique-ish string you 
  added to the URL, `SomeStringSpecificToYou` in the example above)

## Copying changes to the k8s-config-generator repo

After updating the New Relic repo with changes to the Helm chart, those changes will need to be copied
to the FSI copy of our chart: https://source.datanerd.us/fsi/k8s-config-generator/

