# openwrt-turris-omnia-orange-france

Example configuration for Turris Omnia 9 (OpenWrt) for Orange France FTTH.

## Quick Setup

1. **Find your Livebox's MAC address**
   - Check the label/sticker on your Orange Livebox 3
   - It's usually labeled as "MAC address" or "Address" in format `XX:XX:XX:XX:XX:XX`

2. **Edit the network configuration**
   - Copy [`etc/config/network`](etc/config/network) to your router's `/etc/config/network`
   - Replace `11:22:33:AA:BB:CC` with your **Livebox's MAC address** (appears on lines 51, 90)
   - Update `clientid` (line 54) to `01` + MAC without colons (e.g., MAC `aa:bb:cc:dd:ee:ff` → `01aabbccddeeff`)
   - Update `sendopts` line 55 with the same clientid value

3. **Generate XAUTH values** (if needed)
   - Visit: `https://jsfiddle.net/kgersen/3mnsc6wy/`
   - Enter your Orange credentials (identifiant/mot de passe)
   - Copy the generated hex values for options 90 (DHCPv4) and 11 (DHCPv6)

4. **Apply the configuration**
   ```bash
   /etc/init.d/network restart
   ```

5. **Verify connectivity**
   ```bash
   ping -c 4 8.8.8.8
   ping6 -c 4 ipv6.google.com
   ```

## Network Configuration

The [`etc/config/network`](etc/config/network) file contains a working configuration for Orange France FTTH using DHCP over VLAN 832 (instead of PPPoE). It includes:
- LAN bridge with ports lan0-lan4
- WAN interface on VLAN 832 with DHCP client for Livebox 3 compatibility
- IPv6 (DHCPv6) enabled
- Backup PPPoE configuration (disabled) for VLAN 835

### DHCPv4 (WAN) Details
- Uses VLAN 832 on eth2
- Vendor class: `sagem`
- User class: `FSVDSL_livebox.Internet.softathome.Livebox3`
- Client ID: `01` + MAC without colons (must match the `macaddr` value)
- Custom DHCP options for Orange Livebox 3 authentication
- MAC address: **Replace** `11:22:33:AA:BB:CC` with your **Livebox's MAC address** (not your router's)

#### DHCP Option Hex Decoding
The `sendopts` values contain hex-encoded data:
- Option 12 (Hostname): `6c697665626f78` → "livebox"
- Option 60 (Vendor Class): `736167656d` → "sagem"
- Option 77 (User Class): `2b46535644534c5f6c697665626f782e496e7465726e65742e736f66746174686f6d652e4c697665626f7833` → "+FSVDSL_livebox.Internet.softathome.Livebox3"
- Option 90: `XAUTH` (special marker for Orange authentication)

### DHCPv6 (WAN6) Details
- Uses VLAN 832 on eth2
- Client ID: `00030001A23456781926` (static example)
- Requested prefix: auto
- Custom option 11 (RFC 3315) for XAUTH authentication
- Custom option 15 for user class
- Custom option 16 for vendor class
- Custom option 17 for IVPv6 request

#### DHCPv6 Option Hex Decoding
The `sendopts` values contain hex-encoded data:
- Option 11: `XAUTH` (special marker for Orange authentication)
- Option 15 (User Class): `FSVDSL_livebox.Internet.softathome.Livebox3`
- Option 16 (Vendor Class): Enterprise number 1038 (0x040e) + "sagem"
  - `0000040e` = enterprise 1038, `0005736167656d` = "sagem"
- Option 17 (Vendor Info): Enterprise number 1368 (0x0558) + "IPV6_REQUESTED"
  - `00000558` = enterprise 1368, `0006` = length, `495056365f524551554553544544` = "IPV6_REQUESTED"

### PPPoE Backup (Disabled)
- VLAN 835 on eth2 (backup configuration)
- MAC address: **Replace** `11:22:33:AA:BB:CC` with your **Livebox's MAC address** (same as WAN section)
- Username/password placeholders: `fti/replace_with_login` and `replace_with_password`

### XAUTH Generation
The XAUTH values are generated using the JSFiddle tool referenced in the network file:
`https://jsfiddle.net/kgersen/3mnsc6wy/`

Enter your Orange credentials to generate the hex-encoded XAUTH values for both DHCPv4 (option 90) and DHCPv6 (option 11).
