Replace image address `europe-north1-docker.pkg.dev/testailua-223315/testi/cloudrun-chisel-shell:latest` with your own Google Artifact Registry Docker Repository address on `docker-compose.yaml` and accordingly on the following `gcloud` command.

Build & Push Image to Google Artifact Registry Docker Repository
```
docker-compose build
docker-compose push
```

Create Cloud Run Service
```
gcloud alpha run deploy cloudrun-chisel-shell \
   --image europe-north1-docker.pkg.dev/testailua-223315/testi/cloudrun-chisel-shell:latest \
   --update-env-vars CHISEL_USER=user \
   --update-env-vars CHISEL_PASS=passw0rd \
   --update-env-vars AUTHORIZED_KEYS="your ssh public key" \
   --allow-unauthenticated \
   --cpu 1 \
   --memory 512Mi \
   --min-instances 0 \
   --max-instances 3 \
   --execution-environment gen2 \
   --region europe-north1
```

Install Chisel on your own computer
```
sudo wget -O - https://github.com/jpillora/chisel/releases/download/v1.7.7/chisel_1.7.7_linux_amd64.gz | \
gunzip - > /usr/local/bin/chisel
chmod +x /usr/local/bin/chisel
```

SSH to Cloud Run shell through Chisel
```
ssh -o StrictHostKeyChecking=no -o ProxyCommand="chisel client --auth user:passw0rd https://cloudrun-chisel-shell-xyz-lz.a.run.app stdio:localhost:2222" root@localhost
```