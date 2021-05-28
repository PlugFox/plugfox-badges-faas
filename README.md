# plugfox_badges_faas  
  
  
### Hot to build:  
  
```shell  
dart pub run build_runner build --delete-conflicting-outputs  
```  
  
Затем добавить первой строкой в `server.dart` комментарий `// @dart=2.11`  
  
```shell  
dart compile exe bin/server.dart -o bin/server  
```  
  
### Hot to run local:  
  
```shell  
dart run .\bin\server.dart --port 8080  
```  
  
### Config Google Cloud Run  
  
[Quickstart](https://github.com/GoogleCloudPlatform/functions-framework-dart/blob/main/docs/quickstarts/03-quickstart-cloudrun.md)  
[Installing Google Cloud SDK](https://cloud.google.com/sdk/docs/install)  
```shell  
gcloud auth login  
gcloud config set core/project plugfox-badges-faas  
gcloud config set run/platform managed  
gcloud config set run/region europe-west4  
```  
  
  
### Deploy:  
  
[gcloud beta run deploy](https://cloud.google.com/sdk/gcloud/reference/beta/run/deploy)  
```shell  
gcloud beta run deploy plugfox-badges-faas \  
  --source=. \                            # can use $PWD or . for current dir  
  --project=plugfox-badges-faas \         # the Google Cloud project ID  
  --port=8080 \                           # Container port to receive requests at. Also sets the $PORT environment variable.  
  --args='--port 8080' \                  #  
  --set-env-vars \                        #  
  --concurrency=3 \                       #  
  --max-instances=3 \                     #  
  --region=europe-west4 \                 # ex: us-central1  
  --platform managed \                    # for Cloud Run  
  --timeout=25s \                         # Set the maximum request execution time (timeout).  
  --cpu=1 \                               # Set a CPU limit in Kubernetes cpu units.  
  --memory=64Mi \                         #  
  --no-use-http2 \                        #  
  --connectivity=external \               #  
  --allow-unauthenticated                 # for public access  
```