//谁都不明白自己死后应该做点什么——就像人们不知道自己活着应该干什么一样。
import crafttweaker.api.event.entity.MCEntityTravelToDimensionEvent;
import crafttweaker.api.event.entity.player.MCPlayerLoggedInEvent;
import crafttweaker.api.event.entity.MCEntityJoinWorldEvent;
import crafttweaker.api.events.CTEventManager;

CTEventManager.register<MCEntityJoinWorldEvent>((event) => {
    var entity = event.entity;
    if (!entity.world.remote && entity.type.classification == <entityclassification:monster>) event.cancel();
});

CTEventManager.register<MCEntityTravelToDimensionEvent>((event) => {
    if (!event.entity.world.remote && event.dimension.toString() != "lostcities:lostcity") event.cancel();
});

CTEventManager.register<MCPlayerLoggedInEvent>((event) => {
    var player = event.player;
    var world = player.world;
    if (world.remote || world.dimension == "lostcities:lostcity") return;
    var server = world.asServerWorld().server;
    var pos = player.position;
    var pos0 = pos.add(- pos.x, - pos.y, - pos.z);
    var city = server.getWorld(<resource:lostcities:lostcity>);
    server.executeCommand("execute in lostcities:lostcity run tp " + player.uuid + " 0 256 0", true);
    for i in 50 .. 250 {
        if (city.getBlockState(pos0.add(0, i, 0)) == <blockstate:minecraft:air> && city.getBlockState(pos0.add(0, i + 1, 0)) == <blockstate:minecraft:air> && city.asBlockDisplayReader().canSeeSky(pos0.add(0, i, 0))) {
            var y = i + 1;
            server.executeCommand("execute in lostcities:lostcity run tp " + player.uuid + " 0 " + y + " 0", true);
            break;
        }
    } 
    if (city.getBlockState(pos0.add(0, 6, 0)) != <blockstate:minecraft:bedrock>) {
        server.executeCommand("worldborder set 2000", true);
        server.executeCommand("execute in lostcities:lostcity run fill 0 6 0 0 6 0 bedrock", true);
    }
});