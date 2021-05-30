
local SYS  = require "luci.sys"
local ND = SYS.exec("cat /usr/share/adbyby/dnsmasq.adblock | wc -l")

local ad_count = 0
if nixio.fs.access("/usr/share/adbyby/dnsmasq.adblock") then
ad_count = tonumber(SYS.exec("cat /usr/share/adbyby/dnsmasq.adblock | wc -l"))
end

local rule_count = 0
if nixio.fs.access("/usr/share/adbyby/rules/") then
rule_count = tonumber(SYS.exec("/usr/share/adbyby/rule-count '/usr/share/adbyby/rules/'"))
end

m = Map("adbyby")

s = m:section(TypedSection, "adbyby")
s.anonymous = true

o = s:option(Flag, "block_ios")
o.title = translate("Block iOS Update")
o.default = 0
o.rmempty = false

o = s:option(Flag, "block_cnshort")
o.title = translate("Block CNshort Video")
o.default = 0
o.rmempty = false

o = s:option(Flag, "cron_mode")
o.title = translate("Update Rules")
o.default = 0
o.rmempty = false

o = s:option(DummyValue, "ad_data", translate("Rules Datebase"))
o.rawhtml  = true
o.template = "adbyby/refresh"
o.value = ad_count .. " " .. translate("Records")

o = s:option(DummyValue, "rule_data", translate("Subscribe Rules"))
o.rawhtml  = true
o.template = "adbyby/refresh"
o.value = rule_count .. " " .. translate("Records")

o = s:option(Button, "delete", translate("Clear All Subscribe Rules"))
o.inputstyle = "reset"
o.write = function()
  SYS.exec("rm -f /usr/share/adbyby/rules/data/* /usr/share/adbyby/rules/host/*")
  SYS.exec("/etc/init.d/adbyby restart 2>&1 &")
  luci.http.redirect(luci.dispatcher.build_url("admin", "services", "adbyby", "advanced"))
end

o = s:option(DynamicList, "subscribe_url", translate("Subscribe Rules URL"))
o.rmempty = true

return m