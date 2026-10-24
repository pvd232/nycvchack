# nycvchack

Essential setup for [Deal Flow: NYC's First VC Hackathon](https://nyc-vc-hack.devpost.com/), October 24, 2026. Development runs remotely.

## Accounts and credits

All five sponsor accounts are pending registration. Use one Nicrron/Ninoo account and one PRISM workspace per team.

| Service | Signup | Offer / code | Input needed |
| --- | --- | --- | --- |
| Roundtable | [Create account](https://roundtable.bot/sign-up) | Enter `VCHACK` after email verification to open the workspace. | Email and six-digit email code; passwordless. |
| Nicrron / Ninoo | [Create account with promo](https://nicrron.ai/register?code=BETAWORKS250) | `BETAWORKS250`: $250 promo credit plus $10 signup credit. Promo credit expires **October 24, 2026, 11:59 p.m. ET**. One balance covers the API, Builder, and Code CLI. | Name, email, new password, and email confirmation. |
| Akta by Wokelo | [Hackathon signup](https://playground.akta.pro/login?redirectTo=dashboard%2Fmanage%2Fbilling&plan_code=pro_50_1250&source=dealflowhk) | `DEALFLOW50`: first Pro month $0; **renews at $50/month**. Redeem in Stripe checkout. | Name, email, password or Google sign-in; verification. Pro checkout is pending a separate billing decision. |
| PRISM | [Create account](https://prism.blockconvey.com/signup) | `DEALFLOW` in Settings → Billing & usage after the first trace: Builder, 200 credits. | Full name, email, new password, company name, and email confirmation. |
| Solari | [Claim hackathon offer](https://console.getsolari.com/r/VC-HACK1MO-DNNXSYYM) | `VC-HACK1MO-DNNXSYYM`: one month of Starter; participant guide advertises $20 credit. Confirm the balance and renewal terms in Billing. | Email magic link or Google sign-in; passwordless. |

Account creation and credit redemption are unverified until each service shows its workspace and balance.

## Keys

Copy `.env.example` to `.env` on the remote machine and fill the values there. Keep passwords, verification links, API keys, and browser profiles outside Git.

| Service | Key location |
| --- | --- |
| Roundtable | Agents → Connect agent → Assistant. Save the bearer key from the setup prompt; it is shown once. |
| Nicrron | [Dashboard → API keys](https://nicrron.ai/dashboard/keys). API base URL: `https://api.nicrron.ai/v1`. |
| Akta | Dashboard; [API documentation](https://docs.akta.pro). |
| PRISM | Onboarding's “Your PRISM key” or Settings → API Keys; save as `PRISMTRACE_API_KEY`. |
| Solari | Console → API Keys; save the one-time key as `SOLARI_API_KEY`. Close browser and sandbox sessions when finished. |

The variable names in `.env.example` are this repository's storage convention.

## Submission constraints

- Main event submission closes **October 24, 2026, 4 p.m. ET**. Submit the project description, track, one-page founder brief, tools, code URL, live demo URL, and a video of at most three minutes.
- The Best Use of External Data award requires Akta.
- The Nicrron/Ninoo sponsor guide says qualifying entries must use Ninoo Builder, publish a Ninoo Marketplace listing before judging, and route AI calls through Nicrron. **Confirm whether these restrictions apply to the overall event or that sponsor's entry.**
- PRISM's sponsor challenge asks for 20+ runs on fixed inputs and a comparison showing a rule failing in v1 and passing in v2. Use one name per version.

## Dedicated development VM

Requested: one persistent GCP VM accessible to approved identities from other GCP projects. Provisioning is pending GCP reauthentication, the host project, and the caller identities.

Proposed starting size: 2 vCPUs, 8 GB RAM, Ubuntu 24.04, and a 100 GB persistent disk. Keep separate project checkouts and a persistent remote browser profile.

Use OS Login and IAP for SSH. Grant named users or service accounts access in the host project; grant the VM's workload identity access to other projects only for the APIs it needs. Verify outbound internet access for browser and package downloads.

Connection template after provisioning:

```bash
gcloud compute ssh shared-dev \
  --project="$VM_HOST_PROJECT" \
  --zone="$VM_ZONE" \
  --tunnel-through-iap
```

## Sources

Checked October 24, 2026: [event resources](https://nyc-vc-hack.devpost.com/resources), [event requirements](https://nyc-vc-hack.devpost.com/), [Roundtable guide](https://app.notion.com/p/Build-on-Roundtable-hackathon-quick-start-402cdc879e1b80baa982e5c49046787f), [Nicrron/Ninoo guide](https://docs.google.com/document/d/1x2gTHi39wIUNlUZefGzugnYop7oLPNG4/edit), [Solari guide](https://drive.google.com/file/d/1GwP-s9MsDp4vAv7XzWmNSDjWa6e-DW70/view), and [Google's IAP SSH documentation](https://docs.cloud.google.com/compute/docs/connect/ssh-using-iap).
