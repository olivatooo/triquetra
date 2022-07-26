$(".menu .item").tab();

var Money = 0;
function SetMoney(value) {
  let money_element = $("#money");
  Money = value;
  money_element.text(Money);
}

SHOP = {
  health: 0,
  speed: 0,
  size: 0,
  gravity: 0,
  jump: 0,
  ak47: 0,
  ar4: 0,
  glock: 0,
  de: 0,
  shotgun: 0,
  smg: 0,
  awp: 0,
  helmet: 0,
  kevlar: 0,
  launcher: 0,
};

function BuyItem(button) {
  if (SHOP[button] < 3) {
    SHOP[button]++;
    MainBuyItem(button, SHOP[button]);
  }
}

function ResetStore() {
  SHOP = {
    health: 0,
    speed: 0,
    size: 0,
    gravity: 0,
    jump: 0,
    ak47: 0,
    ar4: 0,
    glock: 0,
    de: 0,
    shotgun: 0,
    smg: 0,
    awp: 0,
    helmet: 0,
    kevlar: 0,
    launcher: 0,
  };
  for (const [key, _] of Object.entries(SHOP)) {
    for (var i = 1; i < 4; i++) {
      ItemLevelNegative(key, i);
    }
  }
}

function ItemLevelPositive(item, level) {
  let item_level = $("#" + item + "_" + level);
  item_level.removeClass("disabled");
  item_level.addClass("green");
}

function ItemLevelNegative(item, level) {
  let item_level = $("#" + item + "_" + level);
  item_level.addClass("disabled");
  item_level.removeClass("green");
}
