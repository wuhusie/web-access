---
domain: waimai.meituan.com
aliases: [美团外卖, 美团, h5.waimai.meituan.com]
updated: 2026-08-03
---
## 平台特征
- `www.meituan.com` 是集团官网（企业介绍页），**不含**任何外卖或商户搜索功能，不要从这里入手。
- `waimai.meituan.com` 首页同样是营销/招商页面，无搜索框。
- 真正可用的入口是 H5 版 `h5.waimai.meituan.com/waimai/mindex/home`：游客态即可看到商家列表、评分、月售、起送价、配送费。
- 游客态定位默认锁在**上海同济大学(四平路校区)**，与用户真实位置无关。
- 坐标系为 GCJ-02，与高德地图一致，门店经纬度可直接互用，无需转换。

## 有效模式
- 地址栏元素类名形如 `.addr_XXXXXX`（哈希后缀会变），点击后进入 `/waimai/mindex/poipicker`。
- poipicker 页有两个控件：`.cityListToggle_XXXXXX`（城市切换）和 `.poiInput_XXXXXX`（地址搜索输入框）。
- 给 React 受控 input 赋值需用原生 setter 再派发 input 事件：
  ```js
  const set=Object.getOwnPropertyDescriptor(HTMLInputElement.prototype,"value").set;
  set.call(input, "关键词"); input.dispatchEvent(new Event("input",{bubbles:true}));
  ```

## 已知陷阱（2026-08-03 验证）
- **URL 传 `latitude` / `longitude` 参数无效**，页面完全忽略，定位不会改变。
- **地址搜索框只在当前城市范围内检索**。定位在上海时搜「淮南市人民南路31号」返回空结果，无法跨城市。
- **点击城市切换立即弹出手机号登录框**（`.iLoginComp-phone-num-input`）。因此游客态无法把定位切到其它城市，跨城市商户调研必须先登录。
- 饿了么 `h5.ele.me` 更严格，未登录直接 302 到 `/login/`，游客态什么都看不到。

## 相关：高德 POI 的外卖字段不可用
高德 `place/detail?extensions=all` 返回的 `biz_ext.meal_ordering` 指的是高德自家在线点餐入口，
小商户普遍不填（实测 13 家餐饮店全为 `"0"`），**不能**用来判断美团/饿了么的上线状态。
同一接口的 `rating` / `cost` / `open_time` / `tel` 字段则通常有值，可用。
