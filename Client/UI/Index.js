function TeamDied(index) {
  let teammate = $("#team_" + index);
  teammate.addClass("close negative_neon red");
  teammate.removeClass("user circle positive_neon green");
}

function TeamRevive(index) {
  let enemy = $("#team_" + index);
  enemy.addClass("user circle positive_neon green");
  enemy.removeClass("close negative_neon red");
}

function EnemyDied(index) {
  let enemy = $("#enemy_" + index);
  enemy.addClass("check positive_neon green");
  enemy.removeClass("user circle negative_neon red");
}

function EnemyRevive(index) {
  let enemy = $("#enemy_" + index);
  enemy.removeClass("check positive_neon green");
  enemy.addClass("user circle negative_neon red");
}

function ClearTeamPoint() {
  for (i = 1; i < 4; i++) {
    let team_point = $("#team_point_" + i);
    team_point.removeClass("green");
    team_point.addClass("disabled white");
  }
}

function ClearEnemyPoint() {
  for (i = 1; i < 4; i++) {
    let team_point = $("#enemy_point_" + i);
    team_point.removeClass("red");
    team_point.addClass("disabled white");
  }
}

function ClearPoints() {
  ClearEnemyPoint();
  ClearTeamPoint();
}

function TeamPoint(index) {
  let team_point = $("#team_point_" + index);
  team_point.removeClass("disabled white");
  team_point.addClass("green");
}

function EnemyPoint(index) {
  let enemy_point = $("#enemy_point_" + index);
  enemy_point.removeClass("disabled white");
  enemy_point.addClass("red");
}

function Announce(text, mood) {
  let announce = $("#announce");
  announce.removeClass("negative_neon positive_neon neutral_neon");
  announce.addClass(mood);
  announce.fadeIn(500);
  announce.text(text);
  announce.fadeOut(5000);
}

function SetRoundStatus(text) {
  let round_status = $("#round_status");
  round_status.text(text);
}

function SetHealth(amount) {
  let health = $("#health");
  health.text(amount);
}

function SetActualAmmo(amount) {
  let ammo = $("#actual_ammo");
  ammo.text(amount);
}

function SetAmmoBag(amount) {
  let ammo = $("#ammo_bag");
  ammo.text(amount);
}

function ShowStore() {
  let store = $("#store");
  store.show();
}

function HideStore() {
  let store = $("#store");
  store.hide();
}

function HideAmmo() {
  let ammo = $("#ammo_container");
  ammo.slideUp(200);
}

function ShowAmmo() {
  let ammo = $("#ammo_container");
  ammo.slideDown(200);
}

function MainBuyItem(item, level) {
  Events.Call("BuyItem", item, level);
}

function ConfirmBuyItem(item, level) {
  ItemLevelPositive(item, level);
}

function SetQueue(players) {
  let queue = JSON.parse(players);
  var team_queue_1 = $("#team_queue_1");
  var team_queue_2 = $("#team_queue_2");
  team_queue_1.empty();
  team_queue_2.empty();
  for (let i = 0; i < queue.length; i++) {
    let team_index = queue[i][0];
    let player = queue[i][1];
    AppendToQueue(team_index, player);
  }
}

function AppendToQueue(team_index, player) {
  var team_queue = $("#team_queue_" + team_index);
  team_queue.append("<p>" + player + "</p>");
}

function HideQueue() {
  let queue = $("#queue");
  queue.hide();
}

function ShowQueue() {
  let queue = $("#queue");
  queue.show();
}

function SetScore(players) {
  let queue = JSON.parse(players);
  var team_queue_1 = $("#team_score_1");
  var team_queue_2 = $("#team_score_2");
  team_queue_1.empty();
  team_queue_2.empty();
  for (let i = 0; i < queue.length; i++) {
    let team_index = queue[i][0];
    let player = queue[i][1];
    AppendToScore(team_index, player);
  }
}

function AppendToScore(team_index, player) {
  var team_queue = $("#team_score_" + team_index);
  team_queue.append("<p>" + player + "</p>");
}

function HideScore() {
  let queue = $("#score");
  queue.hide();
}

function ShowScore() {
  let queue = $("#score");
  queue.show();
}

function ApplyPoison(value) {
  let screen = document.getElementById("poison-screen");
  screen.setAttribute("style", "display:block;");
  screen.setAttribute("style", "opacity:" + value / 100);
}

// Subscribe all functions to be used in lua
$(document).ready(function () {
  for (var i in window) {
    if ((typeof window[i]).toString() == "function") {
      Events.Subscribe(window[i].name, window[i]);
    }
  }
});

function ClearUI() {
  HideStore();
  HideAmmo();
  HideScore();
  HideQueue();
}
ClearUI();
