--[[
SHMRT Shanghai Metro Ticket Parser
Parses Shanghai Metro tickets (Fudan FM11RF005).
Usage: script run shmrt_parser
Author: mxcdoam
THE Lookup table was created based on data provided by the TripReader project. (https://github.com/domosekai/tripreader-data)
--]]

local lib14a = require('read14a')
local cmds = require('commands')
local getopt = require('getopt')

local function help()
    print([[shmrt_parser v1.0

Parses Shanghai Metro transport tickets on Fudan FM11RF005SH chips.
Usage:
    script run shmrt_parser
    script run shmrt_parser -d 0002...48hexchars...
    ]]):gsub('\n$', '')
end

local shmrt_stations = {
    ["0111"] = "Xinzhuang", ["0112"] = "Waihuanlu", ["0113"] = "Lianhua Road",
    ["0114"] = "Jinjiang Park", ["0115"] = "Shanghai South Railway Station",
    ["0116"] = "Caobao Road", ["0117"] = "Shanghai Stadium", ["0118"] = "Xujiahui",
    ["0119"] = "Hengshan Road", ["0120"] = "Changshu Road", ["0121"] = "South Shaanxi Road",
    ["0122"] = "South Huangpi Road", ["0123"] = "People's Square", ["0124"] = "Xinzha Road",
    ["0125"] = "Hanzhong Road", ["0126"] = "Shanghai Railway Station",
    ["0127"] = "North Zhongshan Road", ["0128"] = "Yanchang Road",
    ["0129"] = "Shanghai Circus World", ["0130"] = "Wenshui Road",
    ["0131"] = "Pengpu New Village", ["0132"] = "Gongkang Road",
    ["0133"] = "Tonghe New Village", ["0134"] = "Hulan Road",
    ["0135"] = "Gongfu New Village", ["0136"] = "Bao'an Highway",
    ["0137"] = "West Youyi Road", ["0138"] = "Fujin Road",
    ["0234"] = "East Xujing", ["0235"] = "Hongqiao Railway Station",
    ["0236"] = "Hongqiao Airport Terminal 2", ["0237"] = "Songhong Road",
    ["0238"] = "Beixinjing", ["0239"] = "Weining Road", ["0240"] = "Loushanguan Road",
    ["0241"] = "Zhongshan Park", ["0242"] = "Jiangsu Road", ["0243"] = "Jing'an Temple",
    ["0244"] = "West Nanjing Road", ["0245"] = "People's Square",
    ["0246"] = "East Nanjing Road", ["0247"] = "Lujiazui", ["0248"] = "Dongchang Road",
    ["0249"] = "Century Avenue", ["0250"] = "Shanghai Science & Technology Museum",
    ["0251"] = "Century Park", ["0252"] = "Longyang Road",
    ["0253"] = "Zhangjiang Hi-Tech Park", ["0254"] = "Jinke Road",
    ["0255"] = "Guanglan Road", ["0256"] = "Tangzhen",
    ["0257"] = "Middle Chuangxin Road", ["0258"] = "East Huaxia Road",
    ["0259"] = "Chuansha", ["0260"] = "Lingkong Road", ["0261"] = "Yuandong Avenue",
    ["0262"] = "Haitian 3rd Road", ["0263"] = "Pudong International Airport",
    ["0311"] = "Shanghai South Railway Station", ["0312"] = "Shilong Road",
    ["0313"] = "Longcao Road", ["0314"] = "Caoxi Road", ["0315"] = "Yishan Road",
    ["0316"] = "Hongqiao Road", ["0317"] = "West Yan'an Road", ["0318"] = "Zhongshan Park",
    ["0319"] = "Jinshajiang Road", ["0320"] = "Caoyang Road", ["0321"] = "Zhenping Road",
    ["0322"] = "Zhongtan Road", ["0323"] = "Shanghai Railway Station",
    ["0324"] = "Baoshan Road", ["0325"] = "East Baoxing Road",
    ["0326"] = "Hongkou Football Stadium", ["0327"] = "Chifeng Road",
    ["0328"] = "Dabaishu", ["0329"] = "Jiangwan Town", ["0330"] = "West Yingao Road",
    ["0331"] = "South Changjiang Road", ["0332"] = "Songfa Road",
    ["0333"] = "Zhanghuabang", ["0334"] = "Songbin Road", ["0335"] = "Shuichan Road",
    ["0336"] = "Baoyang Road", ["0337"] = "Youyi Road", ["0338"] = "Tieli Road",
    ["0339"] = "North Jiangyang Road",
    ["0401"] = "Shanghai Stadium", ["0402"] = "Yishan Road", ["0403"] = "Hongqiao Road",
    ["0404"] = "West Yan'an Road", ["0405"] = "Zhongshan Park",
    ["0406"] = "Jinshajiang Road", ["0407"] = "Caoyang Road", ["0408"] = "Zhenping Road",
    ["0409"] = "Zhongtan Road", ["0410"] = "Shanghai Railway Station",
    ["0411"] = "Baoshan Road", ["0412"] = "Hailun Road", ["0413"] = "Linping Road",
    ["0414"] = "Dalian Road", ["0415"] = "Yangshupu Road", ["0416"] = "Pudong Avenue",
    ["0417"] = "Century Avenue", ["0418"] = "Pudian Road", ["0419"] = "Lancun Road",
    ["0420"] = "Tangqiao", ["0421"] = "Nanpu Bridge", ["0422"] = "South Xizang Road",
    ["0423"] = "Luban Road", ["0424"] = "Damiqiao Road", ["0425"] = "Dong'an Road",
    ["0426"] = "Shanghai Stadium",
    ["0501"] = "Xinzhuang", ["0502"] = "Chunshen Road", ["0503"] = "Yindu Road",
    ["0505"] = "Zhuanqiao", ["0507"] = "Beiqiao", ["0508"] = "Jianchuan Road",
    ["0509"] = "Dongchuan Road", ["0510"] = "Jinping Road", ["0511"] = "Huaning Road",
    ["0512"] = "Wenjing Road", ["0513"] = "Minhang Development Zone",
    ["0531"] = "Jiangchuan Road", ["0532"] = "Xidu", ["0533"] = "Xiaotang",
    ["0534"] = "Fengpu Avenue", ["0535"] = "East Huancheng Road",
    ["0536"] = "Wangyuan Road", ["0537"] = "Jinhai Lake", ["0538"] = "Fengxian New City",
    ["0621"] = "Oriental Sports Center", ["0622"] = "South Lingyan Road",
    ["0623"] = "Shangnan Road", ["0624"] = "West Huaxia Road", ["0625"] = "Gaoqing Road",
    ["0626"] = "Dongming Road", ["0627"] = "West Gaoke Road",
    ["0628"] = "Linyi New Village", ["0629"] = "Shanghai Children's Medical Center",
    ["0630"] = "Lancun Road", ["0631"] = "Pudian Road", ["0632"] = "Century Avenue",
    ["0633"] = "Yuanshen Sports Center", ["0634"] = "Minsheng Road",
    ["0635"] = "Beiyangjing Road", ["0636"] = "Deping Road", ["0637"] = "Yunshan Road",
    ["0638"] = "Jinqiao Road", ["0639"] = "Boxing Road", ["0640"] = "Wulian Road",
    ["0641"] = "Jufeng Road", ["0642"] = "Dongjing Road", ["0643"] = "Wuzhou Avenue",
    ["0644"] = "Zhouhai Road", ["0645"] = "South Waigaoqiao Free Trade Zone",
    ["0646"] = "Hangjin Road", ["0647"] = "North Waigaoqiao Free Trade Zone",
    ["0648"] = "Gangcheng Road",
    ["0721"] = "Meilan Lake", ["0722"] = "Luonan New Village",
    ["0723"] = "Panguang Road", ["0724"] = "Liuhang", ["0725"] = "Gucun Park",
    ["0726"] = "Qihua Road", ["0727"] = "Shanghai University", ["0728"] = "Nanchen Road",
    ["0729"] = "Shangda Road", ["0730"] = "Changzhong Road", ["0731"] = "Dachang Town",
    ["0732"] = "Xingzhi Road", ["0733"] = "Dahua 3rd Road", ["0734"] = "Xincun Road",
    ["0735"] = "Langao Road", ["0736"] = "Zhenping Road", ["0737"] = "Changshou Road",
    ["0738"] = "Changping Road", ["0739"] = "Jing'an Temple", ["0740"] = "Changshu Road",
    ["0741"] = "Zhaojiabang Road", ["0742"] = "Dong'an Road",
    ["0743"] = "Middle Longhua Road", ["0744"] = "Houtan", ["0745"] = "Changqing Road",
    ["0746"] = "Yaohua Road", ["0747"] = "Yuntai Road", ["0748"] = "West Gaoke Road",
    ["0749"] = "South Yanggao Road", ["0750"] = "Jinxiu Road", ["0751"] = "Fanghua Road",
    ["0752"] = "Longyang Road", ["0753"] = "Huamu Road",
    ["0815"] = "Huizhen Road", ["0816"] = "Dongcheng 1st Road",
    ["0817"] = "Puhang Road", ["0818"] = "Minrui Road", ["0819"] = "Sanlu Highway",
    ["0820"] = "Shendu Highway", ["0821"] = "Lianhang Road", ["0822"] = "Jiangyue Road",
    ["0823"] = "Pujiang Town", ["0824"] = "Luheng Road",
    ["0825"] = "Lingzhao New Village", ["0826"] = "Oriental Sports Center",
    ["0827"] = "Yangsi", ["0828"] = "Chengshan Road", ["0829"] = "Yaohua Road",
    ["0830"] = "China Art Museum", ["0831"] = "South Xizang Road",
    ["0832"] = "Lujiabang Road", ["0833"] = "Laoximen", ["0834"] = "Dashijie",
    ["0835"] = "People's Square", ["0836"] = "Qufu Road",
    ["0837"] = "Zhongxing Road", ["0838"] = "North Xizang Road",
    ["0839"] = "Hongkou Football Stadium", ["0840"] = "Quyang Road",
    ["0841"] = "Siping Road", ["0842"] = "Anshan New Village",
    ["0843"] = "Jiangpu Road", ["0844"] = "Huangxing Road",
    ["0845"] = "Middle Yanji Road", ["0846"] = "Huangxing Park",
    ["0847"] = "Xiangyin Road", ["0848"] = "Nenjiang Road", ["0849"] = "Shiguang Road",
    ["0918"] = "Songjiang South Railway Station", ["0919"] = "Zuibaichi",
    ["0920"] = "Songjiang Sports Center", ["0921"] = "Songjiang New City",
    ["0922"] = "Songjiang University Town", ["0923"] = "Dongjing", ["0924"] = "Sheshan",
    ["0925"] = "Sijing", ["0926"] = "Jiuting", ["0927"] = "Zhongchun Road",
    ["0928"] = "Qibao", ["0929"] = "Xingzhong Road", ["0930"] = "Hechuan Road",
    ["0931"] = "Caohejing Hi-Tech Park", ["0932"] = "Guilin Road",
    ["0933"] = "Yishan Road", ["0934"] = "Xujiahui", ["0935"] = "Zhaojiabang Road",
    ["0936"] = "Jiashan Road", ["0937"] = "Dapuqiao", ["0938"] = "Madang Road",
    ["0939"] = "Lujiabang Road", ["0940"] = "Xiaonanmen", ["0941"] = "Shangcheng Road",
    ["0942"] = "Century Avenue", ["0943"] = "Middle Yanggao Road",
    ["0944"] = "Fangdian Road", ["0945"] = "Lantian Road",
    ["0946"] = "Taierzhuang Road", ["0947"] = "Jinqiao", ["0948"] = "Jinji Road",
    ["0949"] = "Jinhai Road", ["0950"] = "Gutang Road", ["0951"] = "Minlei Road",
    ["0952"] = "Caolu",
    ["1018"] = "Hangzhong Road", ["1019"] = "Ziteng Road",
    ["1020"] = "Longbai New Village", ["1041"] = "Hongqiao Railway Station",
    ["1042"] = "Hongqiao Airport Terminal 2", ["1043"] = "Hongqiao Airport Terminal 1",
    ["1044"] = "Shanghai Zoo", ["1045"] = "Longxi Road", ["1046"] = "Shuicheng Road",
    ["1047"] = "Yili Road", ["1048"] = "Songyuan Road", ["1049"] = "Hongqiao Road",
    ["1050"] = "Jiaotong University", ["1051"] = "Shanghai Library",
    ["1052"] = "South Shaanxi Road", ["1053"] = "Xintiandi", ["1054"] = "Laoximen",
    ["1055"] = "Yuyuan Garden", ["1056"] = "East Nanjing Road",
    ["1057"] = "Tiantong Road", ["1058"] = "North Sichuan Road",
    ["1059"] = "Hailun Road", ["1060"] = "Youdian New Village",
    ["1061"] = "Siping Road", ["1062"] = "Tongji University",
    ["1063"] = "Guoquan Road", ["1064"] = "Wujiaochang",
    ["1065"] = "Jiangwan Stadium", ["1066"] = "Sanmen Road",
    ["1067"] = "East Yingao Road", ["1068"] = "New Jiangwan City",
    ["1069"] = "Guofan Road", ["1070"] = "Shuangjiang Road",
    ["1071"] = "West Gaoqiao", ["1072"] = "Gaoqiao", ["1073"] = "Gangcheng Road",
    ["1074"] = "Jilong Road",
    ["1114"] = "Huaqiao", ["1115"] = "Guangming Road", ["1116"] = "Zhaofeng Road",
    ["1117"] = "Anting", ["1118"] = "Shanghai Automobile City",
    ["1119"] = "East Changji Road", ["1120"] = "Shanghai Circuit",
    ["1131"] = "North Jiading", ["1132"] = "West Jiading", ["1133"] = "Baiyin Road",
    ["1134"] = "Jiading New City", ["1135"] = "Malu", ["1136"] = "Chenxiang Highway",
    ["1137"] = "Nanxiang", ["1138"] = "Taopu New Village", ["1139"] = "Wuwei Road",
    ["1140"] = "Qilianshan Road", ["1141"] = "Liziyuan",
    ["1142"] = "Shanghai West Railway Station", ["1143"] = "Zhenru",
    ["1144"] = "Fengqiao Road", ["1145"] = "Caoyang Road", ["1146"] = "Longde Road",
    ["1147"] = "Jiangsu Road", ["1148"] = "Jiaotong University", ["1149"] = "Xujiahui",
    ["1150"] = "Shanghai Natatorium", ["1151"] = "Longhua", ["1152"] = "Yunjin Road",
    ["1153"] = "Longyao Road", ["1154"] = "Oriental Sports Center",
    ["1155"] = "Sanlin", ["1156"] = "East Sanlin", ["1157"] = "Pusan Road",
    ["1158"] = "Kang'an Road", ["1159"] = "Yuqiao", ["1160"] = "Luoshan Road",
    ["1161"] = "Xiuyan Road", ["1162"] = "Kangxin Highway", ["1163"] = "Disney Resort",
    ["1220"] = "Qixin Road", ["1221"] = "Hongxin Road", ["1222"] = "Gudai Road",
    ["1223"] = "Donglan Road", ["1224"] = "Hongmei Road", ["1225"] = "Hongcao Road",
    ["1226"] = "Guilin Park", ["1227"] = "Caobao Road", ["1228"] = "Longcao Road",
    ["1229"] = "Longhua", ["1230"] = "Middle Longhua Road",
    ["1231"] = "Damiqiao Road", ["1232"] = "Jiashan Road",
    ["1233"] = "South Shaanxi Road", ["1234"] = "West Nanjing Road",
    ["1235"] = "Hanzhong Road", ["1236"] = "Qufu Road", ["1237"] = "Tiantong Road",
    ["1238"] = "International Cruise Terminal", ["1239"] = "Tilanqiao",
    ["1240"] = "Dalian Road", ["1241"] = "Jiangpu Park", ["1242"] = "Ningguo Road",
    ["1243"] = "Longchang Road", ["1244"] = "Aiguo Road", ["1245"] = "Fuxing Island",
    ["1246"] = "Donglu Road", ["1247"] = "Jufeng Road",
    ["1248"] = "North Yanggao Road", ["1249"] = "Jinjing Road",
    ["1250"] = "Shenjiang Road", ["1251"] = "Jinhai Road",
    ["1321"] = "Jinyun Road", ["1322"] = "West Jinshajiang Road",
    ["1323"] = "Fengzhuang", ["1324"] = "South Qilianshan Road",
    ["1325"] = "Zhenbei Road", ["1326"] = "Daduhe Road",
    ["1327"] = "Jinshajiang Road", ["1328"] = "Longde Road", ["1329"] = "Wuning Road",
    ["1330"] = "Changshou Road", ["1331"] = "Jiangning Road",
    ["1332"] = "Hanzhong Road", ["1333"] = "Natural History Museum",
    ["1334"] = "West Nanjing Road", ["1335"] = "Middle Huaihai Road",
    ["1336"] = "Xintiandi", ["1337"] = "Madang Road", ["1338"] = "Expo Museum",
    ["1339"] = "Expo Avenue", ["1340"] = "Changqing Road",
    ["1341"] = "Chengshan Road", ["1342"] = "Dongming Road",
    ["1343"] = "Huapeng Road", ["1344"] = "Xianan Road", ["1345"] = "Beicai",
    ["1346"] = "Chenchun Road", ["1347"] = "Lianxi Road",
    ["1348"] = "Middle Huaxia Road", ["1349"] = "Zhongke Road",
    ["1350"] = "Xuelin Road", ["1351"] = "Zhangjiang Road",
    ["1421"] = "Fengbang", ["1422"] = "Lexiu Road", ["1423"] = "Lintao Road",
    ["1424"] = "Jiayi Road", ["1425"] = "Dingbian Road",
    ["1426"] = "Zhenxin New Village", ["1427"] = "Zhenguan Road",
    ["1428"] = "Tongchuan Road", ["1429"] = "Zhenru", ["1430"] = "Zhongning Road",
    ["1431"] = "Caoyang Road", ["1432"] = "Wuning Road", ["1433"] = "Wuding Road",
    ["1434"] = "Jing'an Temple", ["1435"] = "South Huangpi Road",
    ["1436"] = "Dashijie", ["1437"] = "Yuyuan Garden", ["1438"] = "Lujiazui",
    ["1439"] = "South Pudong Road", ["1440"] = "Pudong Avenue",
    ["1441"] = "Yuanshen Road", ["1442"] = "Changyi Road", ["1443"] = "Xiepu Road",
    ["1444"] = "Longju Road", ["1445"] = "Yunshan Road", ["1446"] = "Lantian Road",
    ["1447"] = "Huangyang Road", ["1448"] = "Yunshun Road",
    ["1449"] = "Pudong Football Stadium", ["1450"] = "Jinyue Road",
    ["1451"] = "Guiqiao Road",
    ["1521"] = "Zizhu Hi-Tech Park", ["1522"] = "Yongde Road",
    ["1523"] = "Yuanjiang Road", ["1524"] = "Shuangbai Road",
    ["1525"] = "Shujian Road", ["1526"] = "Jingxi Road",
    ["1527"] = "South Hongmei Road", ["1528"] = "West Huajing",
    ["1529"] = "Zhumei Road", ["1530"] = "Luoxiu Road",
    ["1531"] = "East China University of Science and Technology",
    ["1532"] = "Shanghai South Railway Station", ["1533"] = "Guilin Park",
    ["1534"] = "Guilin Road", ["1535"] = "Wuzhong Road", ["1536"] = "Yaohong Road",
    ["1537"] = "Hongbaoshi Road", ["1538"] = "Loushanguan Road",
    ["1539"] = "Changfeng Park", ["1540"] = "Daduhe Road",
    ["1541"] = "North Meiling Road", ["1542"] = "Tongchuan Road",
    ["1543"] = "Shanghai West Railway Station", ["1544"] = "East Wuwei Road",
    ["1545"] = "Gulang Road", ["1546"] = "Qi'an Road", ["1547"] = "Nanda Road",
    ["1548"] = "Fengxiang Road", ["1549"] = "Jinqiu Road", ["1550"] = "Gucun Park",
    ["1621"] = "Longyang Road", ["1622"] = "Middle Huaxia Road",
    ["1623"] = "Luoshan Road", ["1624"] = "East Zhoupu",
    ["1625"] = "Hesha Hangcheng", ["1626"] = "East Hangtou", ["1627"] = "Xinchang",
    ["1628"] = "Shanghai Wild Animal Park", ["1629"] = "Huinan",
    ["1630"] = "East Huinan", ["1631"] = "Shuyuan", ["1632"] = "Lingang Avenue",
    ["1633"] = "Dishui Lake",
    ["1721"] = "Hongqiao Railway Station", ["1722"] = "Zhuguang Road",
    ["1723"] = "Panlong Road", ["1724"] = "Xuying Road",
    ["1725"] = "North Xujing Town", ["1726"] = "Middle Jiasong Road",
    ["1727"] = "Zhaoxiang", ["1728"] = "Huijin Road", ["1729"] = "Qingpu New City",
    ["1730"] = "Caoying Road", ["1731"] = "Dianshan Lake Avenue",
    ["1732"] = "Zhujiajiao", ["1733"] = "Oriental Land", --[[["1737"] = "Zhujiajiao",]]--
    ["1821"] = "Hangtou", ["1822"] = "Xiasha", ["1823"] = "Hetao Road",
    ["1824"] = "Shenmei Road", ["1825"] = "Fanrong Road", ["1826"] = "Zhoupu",
    ["1827"] = "Kangqiao", ["1828"] = "Yuqiao", ["1829"] = "Lianxi Road",
    ["1830"] = "Beizhong Road", ["1831"] = "Fangxin Road",
    ["1832"] = "Longyang Road", ["1833"] = "Yingchun Road",
    ["1834"] = "Middle Yanggao Road", ["1835"] = "Minsheng Road",
    ["1836"] = "Changyi Road", ["1837"] = "Danyang Road",
    ["1838"] = "Pingliang Road", ["1839"] = "Jiangpu Park",
    ["1840"] = "Jiangpu Road", ["1841"] = "Fushun Road", ["1842"] = "Guoquan Road",
    ["1843"] = "Fudan University", ["1844"] = "Shanghai University of Finance and Economics",
    ["1845"] = "Yingao Road", ["1846"] = "South Changjiang Road",
    ["2221"] = "Shanghai South", ["2222"] = "Xinzhuang", ["2223"] = "Chunshen",
    ["2224"] = "Xinqiao", ["2225"] = "Chedun", ["2226"] = "Yexie",
    ["2227"] = "Tinglin", ["2228"] = "Jinshan Park", ["2229"] = "Jinshanwei",
    ["9001"] = "Pudong International Airport", ["9002"] = "Longyang Road",
}

local function center_text(s, w)
    local len = #s
    if len >= w then return s end
    local pad = w - len
    local left = math.floor(pad / 2)
    local right = pad - left
    return string.rep(" ", left) .. s .. string.rep(" ", right)
end

local function is_leap(y)
    return (y % 4 == 0 and y % 100 ~= 0) or y % 400 == 0
end

local function ts_to_date(ts)
    local dim = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
    local days = math.floor(ts / 86400)
    local time_secs = ts % 86400
    local hour = math.floor(time_secs / 3600)
    local min = math.floor((time_secs % 3600) / 60)
    local sec = time_secs % 60
    local y = 1970
    while true do
        local diy = is_leap(y) and 366 or 365
        if days < diy then break end
        days = days - diy
        y = y + 1
    end
    for m = 1, 12 do
        local d = dim[m]
        if m == 2 and is_leap(y) then d = 29 end
        if days < d then
            return {year = y, month = m, day = days + 1, hour = hour, min = min, sec = sec}
        end
        days = days - d
    end
end

local function fmt_date(t)
    return string.format("%02d-%02d-%04d", t.day, t.month, t.year)
end

local function fmt_time(t)
    return string.format("%02d:%02d:%02d", t.hour, t.min, t.sec)
end

local function hex_to_bytes(hex)
    local bytes = {}
    for i = 1, #hex, 2 do
        bytes[#bytes + 1] = tonumber(hex:sub(i, i + 1), 16)
    end
    return bytes
end

local function bytes_to_u16_be(bytes, offset)
    return (bytes[offset] << 8) | bytes[offset + 1]
end

local function bytes_to_u32_be(bytes, offset)
    return (bytes[offset] << 24) | (bytes[offset + 1] << 16) |
           (bytes[offset + 2] << 8) | bytes[offset + 3]
end

local function lookup_station(id)
    if id == nil or id == 0 then
        return nil
    end
    return shmrt_stations[string.format("%04X", id)]
end

local function parse_shmrt(raw_hex)
    if not raw_hex or #raw_hex < 48 then
        print("  (incomplete data)")
        return
    end

    print("\x1B[2J\x1B[H")

    local bytes = hex_to_bytes(raw_hex)
    -- raw_hex covers pages 2-7 = 24 bytes = 48 hex chars
    -- bytes[1..24] correspond to card bytes 8..31

    local flags = bytes_to_u16_be(bytes, 1)
    local sta_id = bytes_to_u16_be(bytes, 13)
    local machine = bytes[15]
    local ticket_type = bytes[16]
    local ts_raw = bytes_to_u32_be(bytes, 17)
    local fare_raw = bytes_to_u16_be(bytes, 21)
    local cashier = bytes_to_u16_be(bytes, 23)

    local header_line = string.rep("=", 40)
    print(header_line)
    print(center_text("SHANGHAI METRO TICKET", 40))
    print(header_line)

    if ticket_type == 0x64 then
        print("  Type: Single Journey Ticket")

        local fare_cents = fare_raw
        print(string.format("  Fare: %u.%02u CNY", fare_cents / 100, fare_cents % 100))

        if ts_raw ~= 0xFFFFFFFF then
            local dt = ts_to_date(ts_raw)
            print("  Issued on: " .. fmt_date(dt))
            print("  Issue time: " .. fmt_time(dt))
        end

    elseif ticket_type == 0x84 then
        print("  Type: 1-day pass")

    elseif ticket_type == 0x88 then
        print("  Type: 3-day pass")

    else
        print(string.format("  Type: Unknown (0x%02X)", ticket_type))
    end

    local line_bcd = (sta_id >> 8) & 0xFF
    local line = ((line_bcd >> 4) * 10) + (line_bcd & 0xF)

    local name = lookup_station(sta_id)
    if name then
        print("  STA: " .. name)
        print("  Line " .. line)
    else
        print(string.format("  STA ID: %04X", sta_id))
    end

    print(string.format("  Machine ID: %X/%d", sta_id, machine))

    if cashier == 0 then
        print("  Issued via: TVM")
    else
        print("  Issued via: DESK")
        print(string.format("  Cashier ID: %X", cashier))
    end
end

local function parseResponse(raw)
    local resp = Command.parse(raw)
    local len = tonumber(resp.arg1) * 2
    if len and len > 0 then
        return string.sub(tostring(resp.data), 0, len)
    end
    return nil
end

local function do_read_card()
    core.clearCommandBuffer()

    -- Select card, leave field on (lib14a.read with dont_disconnect + no_rats)
    local info, err = lib14a.read(true, true)
    if not info then
        print("ERROR: card select failed (" .. tostring(err) .. ")")
        lib14a.disconnect()
        return
    end
    print("Card: detected (SAK=" .. (info.sak or "?") .. ")")

    -- Flags matching CLI: hf 14a raw -a -c -k <hex>
    -- = NO_DISCONNECT | APPEND_CRC | NO_SELECT | RAW
    local flags = lib14a.ISO14A_COMMAND.ISO14A_NO_DISCONNECT
                + lib14a.ISO14A_COMMAND.ISO14A_APPEND_CRC
                + lib14a.ISO14A_COMMAND.ISO14A_NO_SELECT
                + lib14a.ISO14A_COMMAND.ISO14A_RAW

    local blocks = {2, 3, 4, 5, 6, 7}
    local data_hex = ""
    local ok = true

    for _, b in ipairs(blocks) do
        local raw_hex = string.format("30%02x", b)
        local byte_count = #raw_hex / 2

        local cmd = Command:newMIX{
            cmd = cmds.CMD_HF_ISO14443A_READER,
            arg1 = flags,
            arg2 = byte_count,
            data = raw_hex
        }
        local result, err = cmd:sendMIX()
        if not result then
            print(string.format("ERROR: failed to read block %d (%s)", b, err or "no response"))
            ok = false
            break
        end

        local resp_hex = parseResponse(result)
        if resp_hex then
            local block_hex = resp_hex:sub(1, -5)
            data_hex = data_hex .. block_hex
        else
            print(string.format("ERROR: failed to read block %d", b))
            ok = false
            break
        end
    end

    lib14a.disconnect()

    if not ok or #data_hex < 48 then
        if #data_hex < 48 then
            print(string.format("ERROR: incomplete data (%d hex chars, need 48)", #data_hex))
        end
        return
    end

    parse_shmrt(data_hex)
end

local function main(args)
    for o, a in getopt.getopt(args, 'hd:') do
        if o == 'h' then return help() end
        if o == 'd' then
            local data = a:gsub("%s+", "")
            if #data >= 48 then
                data = data:sub(-48)
            end
            return parse_shmrt(data)
        end
    end

    while true do
        print("")
        print("1> Read a Shanghai Metro Ticket")
        print("0> Exit")
        io.write("Choose: ")
        local choice = (io.read() or ""):gsub("\r", "")
        if choice == "0" then
            break
        elseif choice == "1" then
            do_read_card()
        else
            print("Invalid choice")
        end
    end

end

main(args)
