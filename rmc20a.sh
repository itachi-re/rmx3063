echo "--- Starting Full Firmware Flash ---"

# 1. Flash Verified Boot partitions to ensure integrity checks pass
echo "[1/12] Flashing vbmeta..."
fastboot flash vbmeta vbmeta.img
echo "[2/12] Flashing vbmeta_system..."
fastboot flash vbmeta_system vbmeta_system.img
echo "[3/12] Flashing vbmeta_vendor..."
fastboot flash vbmeta_vendor vbmeta_vendor.img

# 2. Flash low-level bootloader and security components
echo "[4/12] Flashing lk (bootloader)..."
fastboot flash lk lk.img
echo "[5/12] Flashing tee (Trusted Execution Environment)..."
fastboot flash tee tee.img

# 3. Flash core boot and hardware description images
echo "[6/12] Flashing boot (kernel)..."
fastboot flash boot boot.img
echo "[7/12] Flashing dtbo (Device Tree)..."
fastboot flash dtbo dtbo.img
echo "[8/12] Flashing logo (Boot Logo)..."
fastboot flash logo logo.bin

# 4. Flash main OS and recovery partitions
echo "[9/12] Flashing recovery..."
fastboot flash recovery recovery.img
echo "[10/12] Flashing super (System, Vendor, Product). THIS WILL TAKE A LONG TIME..."
fastboot flash super super.img

# 5. Flash userdata partition (clean image-based data flash)
echo "[11/12] Flashing userdata..."
fastboot flash userdata userdata.img

# 6. Flash modem firmware to ensure cellular connectivity works
echo "[12/12] Flashing modem..."
fastboot flash md1img md1img.img

# 7. WIPE ALL DATA for a clean installation. THIS IS A FACTORY RESET.
echo "--- Wiping all user data... ---"
fastboot erase userdata

# 8. Reboot your device
echo "--- Flash Complete! Rebooting now. The first boot may take several minutes. ---"
fastboot reboot
