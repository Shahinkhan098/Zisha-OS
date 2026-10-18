# ⚡ Zisha OS 1.0 — AI, Web Dev, Security & Office Edition

**Zisha OS** হলো **Debian 12 (Bookworm) Stable**-এর ওপর ভিত্তি করে তৈরি আপনার নিজস্ব, নিরাপদ, সুপার-ফাস্ট এবং কাস্টমাইজড অপারেটিং সিস্টেম। এটি বিশেষভাবে ডিজাইন করা হয়েছে:
1. **ওয়েব ও সফটওয়্যার ডেভেলপমেন্ট** (Node.js, Bun, pnpm, Docker, Python, Git, VSCodium/VS Code)
2. **CPU-Optimized AI ইঞ্জিনিয়ারিং** (আলাদা গ্রাফিক্স কার্ড ছাড়াই CPU ও বিল্ট-ইন গ্রাফিক্সে দ্রুত লোকাল LLM, Ollama AVX2, CPU-Only PyTorch, FastAPI, LangChain, ChromaDB)
3. **সর্বোচ্চ সাইবার সিকিউরিটি ও প্রাইভেসি** (LUKS2 Full Disk Encryption, UFW Localhost-Isolated Firewall, Kernel Hardening, AppArmor, এবং Git API Key Leak Blocker)
4. **বাংলা ও ইংরেজি অফিসের ১০০% কাজ** (অভ্র ফোনেটিক + বিজয়/ইউনিজয় কিবোর্ড, সব বাংলা ও মাইক্রোসফট ফন্ট, OnlyOffice + LibreOffice, বাংলা OCR, এবং বিল্ট-ইন অফলাইন **ইউনিকোড ⇄ বিজয় কনভার্টার**)

---

## 📁 প্রজেক্ট স্ট্রাকচার (Project Architecture)

```text
Zisha-OS/
├── build-zisha-os.ps1                                   # Windows থেকে এক ক্লিকে ISO বিল্ড ও ম্যানেজমেন্ট স্ক্রিপ্ট
├── Dockerfile.isobuilder                                # Debian 12 Live-Build Docker কন্টেইনার
├── scripts/
│   ├── build-iso.sh                                     # বুটেবল zisha-os-1.0-amd64.iso জেনারেটর
│   ├── install-on-existing-linux.sh                     # যেকোনো Debian/Ubuntu সিস্টেমকে Zisha OS-এ রূপান্তর করার স্ক্রিপ্ট
│   └── modules/
│       ├── 01-security-performance.sh                   # সিকিউরিটি হার্ডেনিং, ফায়ারওয়াল, zram ও Git সিক্রেট প্রোটেকশন
│       ├── 02-bengali-english-office.sh                 # অভ্র + বিজয় কিবোর্ড, ফন্ট, OnlyOffice, LibreOffice ও বাংলা OCR
│       ├── 03-webdev-ai-stack.sh                        # Web Dev টুলস ও CPU-Optimized AI স্ট্যাক
│       └── 04-desktop-ui.sh                             # হালকা ও আধুনিক XFCE4 ডেস্কটপ (~৪৫০ MB RAM)
└── config/includes.chroot/
    ├── etc/os-release                                   # Zisha OS অফিশিয়াল ব্র্যান্ডিং
    ├── etc/motd                                         # Zisha OS টার্মিনাল ব্যানার
    ├── etc/sysctl.d/99-zisha-os-hardening.conf          # কার্নেল সিকিউরিটি ও পারফরম্যান্স টিউনিং
    ├── usr/local/bin/zisha-ai-setup                     # CPU ও RAM অনুযায়ী লোকাল AI মডেল ইনস্টলার
    ├── usr/local/bin/zisha-security-audit               # সিকিউরিটি ও প্রাইভেসি হেলথ চেকার
    ├── usr/local/bin/zisha-bangla-converter             # অফলাইন বাংলা কনভার্টার লঞ্চার
    └── usr/share/zisha-os/bangla-converter/index.html   # ১০০% অফলাইন ইউনিকোড ⇄ বিজয় কনভার্টার ও অফিস ড্রাফট প্যাড
```

---

## 🚀 কীভাবে ব্যবহার ও বিল্ড করবেন (Quick Start Guide)

### ১. প্রজেক্ট যাচাই এবং `Zisha-OS` ফোল্ডারে সিঙ্ক করা
PowerShell ওপেন করে চালান:
```powershell
.\build-zisha-os.ps1 -Action Validate
.\build-zisha-os.ps1 -Action SyncProjectFolder
```

### ২. এক কমান্ডে বুটেবল `.ISO` ফাইল তৈরি করা (`zisha-os-1.0-amd64.iso`)
আপনার পিসিতে **Docker Desktop** বা **WSL2** চালু রেখে নিচের কমান্ডটি দিন:
```powershell
.\build-zisha-os.ps1 -Action BuildISO
```
বিল্ড শেষ হলে `output/zisha-os-1.0-amd64.iso` ফাইলটি তৈরি হয়ে যাবে। এরপর **Rufus** বা **Ventoy** দিয়ে পেনড্রাইভে বুটেবল করে সরাসরি পিসিতে (Dual-Boot বা Main OS হিসেবে) অথবা **VirtualBox**-এ ইনস্টল করতে পারবেন।

### ৩. এখনই অফলাইন বাংলা কনভার্টার ও অফিস প্যাড ব্যবহার করুন!
আপনি আপনার বর্তমান Windows পিসিতে বসেও **Zisha OS**-এর অফলাইন **ইউনিকোড ⇄ বিজয় কনভার্টার** এবং অফিস ড্রাফট প্যাডটি ওপেন করে কাজ করতে পারেন:
```powershell
.\build-zisha-os.ps1 -Action OpenBanglaConverter
```

---

## ⌨️ Zisha OS-এর শর্টকাট ও কমান্ডসমূহ
* **`Super + Space` অথবা `Ctrl + Space`**: মুহূর্তের মধ্যে **English ⇄ অভ্র (Avro Phonetic) ⇄ বিজয় (Unijoy)** কিবোর্ড পরিবর্তন।
* **`zisha-ai-setup`**: আপনার CPU ও RAM অনুযায়ী হালকা অফলাইন কোডিং ও চ্যাট AI মডেল (`qwen2.5-coder:1.5b` / `llama3.2:1b`) এবং CPU-Only PyTorch ওয়ার্কস্পেস রেডি করে।
* **`zisha-security-audit`**: ফায়ারওয়াল, লোকালহোস্ট আইসোলেশন, কার্নেল হার্ডেনিং ও গিট সিক্রেট প্রোটেকশন পরীক্ষা করে।
* **`zisha-bangla-converter`**: ইন্টারনেট ছাড়াই ইউনিকোড (Nikosh/Avro) ও বিজয় (SutonnyMJ) ফন্ট কনভার্ট এবং দাপ্তরিক চিঠির ড্রাফট তৈরি করে।
