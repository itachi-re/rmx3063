# rmx3063
rmx 3063 aka realme c20a / c20 mtk 6765 device tools &amp; scripts
# 📱 Realme RMX3063 (Realme C21) Guide

This repository contains comprehensive guides and tools for the Realme RMX3063, focusing on decrypting official firmware and unlocking the bootloader using MTK exploits on Linux systems.

---

## ⚠️ Disclaimer

**READ THIS CAREFULLY BEFORE PROCEEDING**

The procedures described here are for **advanced users only**. Unlocking the bootloader and modifying your device's software will:

- ❌ **VOID YOUR WARRANTY**
- 🗑️ **ERASE ALL YOUR DATA**
- ⚠️ Potentially brick your device if done incorrectly

By proceeding with these steps, you accept **full responsibility** for any potential damage to your device. I am **not liable** if your device becomes bricked, damaged, or unresponsive.

---

## 📋 Table of Contents

- [Part 1: Decrypting Official OZIP Firmware](#part-1-decrypting-official-ozip-firmware)
- [Part 2: Unlocking the Bootloader with MTK Exploit](#part-2-unlocking-the-bootloader-with-mtk-exploit)
- [Contributing](#contributing)
- [Support](#support)

---

## 🔓 Part 1: Decrypting Official OZIP Firmware

Realme firmware for the RMX3063 comes in an encrypted `.ozip` format. To access the raw system images (`super.img`, `boot.img`, etc.), you must first decrypt this file.

### 📦 Prerequisites

- 🐧 A Linux environment (Ubuntu, Debian, Arch, openSUSE, etc.)
- 🐍 **Python 3** and **pip** installed
- 📥 Official `.ozip` firmware file for RMX3063 (downloadable from Realme support website)

### 🛠️ Steps to Decrypt

#### 1. Clone the Decryption Tool

First, clone the `oppo-ozip-decrypt` repository:

```bash
git clone https://github.com/bkerler/oppo_ozip_decrypt.git
cd oppo_ozip_decrypt
```

#### 2. Install Dependencies

Install the required Python libraries:

```bash
pip3 install -r requirements.txt
```

#### 3. Run the Decryption Script

Place your downloaded `.ozip` file inside the `oppo_ozip_decrypt` folder, then run:

```bash
python3 ozipdecrypt.py firmware_file.ozip
```

Replace `firmware_file.ozip` with your actual firmware filename. The script will output a decrypted `.zip` file.

#### 4. Extract the Images

Extract the decrypted archive to access partition images:

```bash
unzip decrypted_firmware.zip
```

You now have access to `super.img`, `boot.img`, and other partition images! ✅

---

## 🔐 Part 2: Unlocking the Bootloader with MTK Exploit

The Realme RMX3063 does not have an official bootloader unlock method. We'll use a low-level exploit for its MediaTek (MTK) chipset to force the unlock.

### 📦 Prerequisites

- 🐧 A Linux environment
- 🔧 **MTK Client Tool** - Powerful utility for MediaTek devices in BROM mode
- 📚 **libusb** - Library for USB device access
- 📱 Realme RMX3063 device and USB cable
- 💾 **Complete backup of your data** (seriously!)

### 🛠️ Steps to Unlock

#### 1. Install System Dependencies

Choose your distribution:

##### 🔵 Debian/Ubuntu

```bash
sudo apt-get update
sudo apt-get install python3-pip libusb-1.0-0-dev git
```

##### 🔷 Arch/Manjaro

```bash
sudo pacman -Syu
sudo pacman -S python-pip libusb git
```

##### 🟢 openSUSE Tumbleweed

```bash
sudo zypper refresh
sudo zypper install python3-pip libusb-1_0-devel git
```

#### 2. Clone the MTK Client

Clone the `mtkclient` repository:

```bash
git clone https://github.com/bkerler/mtkclient.git
cd mtkclient
```

#### 3. Install Python Requirements

Install required Python libraries:

```bash
pip3 install -r requirements.txt
```

#### 4. Prepare Your Device

- 💾 **BACK UP ALL YOUR DATA** - This process will completely wipe your phone!
- 🔌 **Power off** your RMX3063 completely
- 🔋 Ensure your device has at least 50% battery

#### 5. Enter BROM Mode and Unlock

This is the **crucial step**. Timing is important here! ⏰

1. Open a terminal in the `mtkclient` directory
2. Execute the unlock command:

```bash
python3 mtk e metadata,userdata,md_udc unlock_bootloader
```

3. **Immediately after running the command:**
   - Press and hold **Volume Up + Volume Down** buttons simultaneously on your powered-off phone
   - While holding both buttons, connect your phone to the computer via USB
   - **Keep holding the buttons** until the terminal detects the device

4. The terminal should detect the device in BROM mode and begin the unlocking process
5. Wait for the script to complete. It will erase specified partitions and unlock the bootloader

#### 6. Verify the Unlock

- 🔌 Disconnect your device once the script finishes
- 🔄 Reboot by holding the power button
- 🎉 You should see a warning message on startup indicating the bootloader is **unlocked**

**Congratulations!** 🎊 You can now flash custom images, GSIs, or custom recoveries!

---

## 🤝 Contributing

Contributions are welcome! If you have improvements, additional guides, or fixes:

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/improvement`)
5. Open a Pull Request

---

## 💬 Support

- 🐛 Found a bug? Open an [issue](../../issues)
- 💡 Have a question? Check existing [discussions](../../discussions)
- 📖 Need help? Read the guides carefully and ensure all prerequisites are met

---

## 📄 License

This project is provided as-is for educational purposes. Use at your own risk.

---

## 🙏 Credits

- [bkerler](https://github.com/bkerler) - For the amazing MTK Client and OZIP decrypt tools
- The Android modding community for their continuous contributions

---

<div align="center">
  
**⭐ If this guide helped you, please consider giving it a star! ⭐**

Made with ❤️ for the Realme RMX3063 community

</div>
