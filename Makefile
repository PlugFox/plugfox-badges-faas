login:
	@gcloud login

deploy:
	@gcloud beta run deploy plugfox-badges-faas \
	  --source=. \
	  --project=plugfox-badges-faas \
	  --service-account=plugfox-badges-cloud-run@plugfox-badges-faas.iam.gserviceaccount.com \
	  --port=8080 \
	  --args='--port 8080' \
	  --set-env-vars=URL="badges.plugfox.dev/dart_rank.svg" \
	  --concurrency=2 \
	  --min-instances=0 \
	  --max-instances=2 \
	  --region=europe-west4 \
	  --platform managed \
	  --timeout=15s \
	  --cpu=1 \
	  --memory=128Mi \
	  --no-use-http2 \
	  --ingress=all \
	  --allow-unauthenticated \
	  --tag=plugfox-badges
