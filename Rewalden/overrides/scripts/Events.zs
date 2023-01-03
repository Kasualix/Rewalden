import crafttweaker.api.event.entity.MCEntityTravelToDimensionEvent;
import crafttweaker.api.event.entity.player.MCPlayerLoggedInEvent;
import crafttweaker.api.event.entity.player.MCPlayerRespawnEvent;
import crafttweaker.api.event.entity.MCEntityJoinWorldEvent;
import crafttweaker.api.event.tick.MCPlayerTickEvent;
import crafttweaker.api.events.CTEventManager;

CTEventManager.register<MCEntityJoinWorldEvent>((event) => {
    var entity = event.entity;
    if (!entity.world.remote && entity.type.classification == <entityclassification:monster>) event.cancel();
});

CTEventManager.register<MCPlayerRespawnEvent>((event) => {
    var player = event.player;
    if (player.world.remote) return;
    player.addGameStage("death");
});

CTEventManager.register<MCPlayerTickEvent>((event) => {
    var player = event.player;
    var world = player.world;
    if (world.remote) return;
    if (player.hasGameStage("death") && !player.isSpectator()) {
        world.asServerWorld().server.executeCommand("gamemode spectator " + player.name.formattedText, true);
    }
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