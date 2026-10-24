# Dev VM

`dev` provides a persistent remote terminal and Chrome desktop for work across GCP projects.

| Setting | Value |
| --- | --- |
| Host project | Devbox (`pvd-dev-232`) |
| Zone | `us-central1-a` |
| Machine | `e2-standard-2`: 2 vCPUs, 8 GB RAM |
| OS | Ubuntu 24.04 |
| Disk | 100 GB balanced persistent disk; retained if the VM is deleted |
| Network | Private IP `10.242.25.2`; Cloud NAT for outbound internet |
| Login | Columbia Google account, OS Login, and IAP |
| Workspace | `/srv/projects`, owned by local user `dev` |
| Browser state | `/home/dev/browser-profile` |

## Terminal

The Aether VM has a verified SSH alias:

```bash
ssh dev
sudo -iu dev
cd /srv/projects
```

From Cloud Shell or another GCP project, use the host project explicitly. Set `GCP_ACCOUNT` to the Columbia account you authenticated with:

```bash
gcloud compute ssh dev \
  --account="$GCP_ACCOUNT" --project=pvd-dev-232 --zone=us-central1-a \
  --tunnel-through-iap
```

IAP works across project boundaries using the caller's authorized identity. Private VPC peering is unnecessary for this SSH path. Additional service accounts require their own access grants. Grant workload API permissions separately in each target project when needed.

## Browser desktop

For an entirely remote session, open [Cloud Shell](https://shell.cloud.google.com/) with the Columbia account. Retrieve the desktop password in its terminal:

```bash
gcloud compute ssh dev --project=pvd-dev-232 --zone=us-central1-a \
  --tunnel-through-iap \
  --command='sudo cat /home/dev/.config/shared-dev/vnc-password'
```

Then start a tunnel and use Cloud Shell's **Web Preview → Preview on port 8080**:

```bash
gcloud compute ssh dev --project=pvd-dev-232 --zone=us-central1-a \
  --tunnel-through-iap -- -N -L 8080:127.0.0.1:6080
```

Enter the retrieved password in the desktop viewer. Chrome's profile persists between sessions. Desktop ports listen on loopback and are reached through SSH.

## Start and stop

```bash
gcloud compute instances stop dev --project=pvd-dev-232 --zone=us-central1-a
gcloud compute instances start dev --project=pvd-dev-232 --zone=us-central1-a
```

Run these commands under the Columbia account. The disk and Cloud NAT remain allocated while the VM is stopped.

The [bootstrap script](infra/bootstrap.sh) installs Python, Node.js, Git, GitHub CLI, Google Cloud CLI, Chrome, and the desktop services. Credentials and browser state stay outside this repository.

References: [Google's IAP connection guide](https://docs.cloud.google.com/compute/docs/connect/ssh-using-iap) and [IAP access controls](https://docs.cloud.google.com/iap/docs/using-tcp-forwarding), checked October 24, 2026.
