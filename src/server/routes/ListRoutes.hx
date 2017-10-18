package routes;

import tink.web.forms.FormFile;
import tink.web.routing.*;

import types.TPrivacy;

using Lambda;
using StringTools;
using haxe.io.Path;

class ListRoutes {
    public function new() {}
    
    @:get('/$listHash') public function getList(listHash:String, user:JWTSession.User):Response {
        var lid:Int = try { Server.extractID(listHash, Server.listHID); } catch(e:Dynamic) return new response.NotFound();

        // TODO: make sure we have permission to view this list
        var list:models.List = models.List.manager.get(lid);
        if(list == null) {
            return new response.NotFound('list "${listHash}"');
        }
        return new response.API<api.List>(list);
    }
    
    @:get('/$listHash/items') public function getListItems(listHash:String, user:JWTSession.User):Response {
        var u:models.User = models.User.manager.get(user.id);
        if(u == null) return new response.NotFound();

        // TODO: make sure we have permission to view this list!

        var id:Int = try { Server.extractID(listHash, Server.listHID); } catch(e:Dynamic) return new response.NotFound();
        var list:models.List = models.List.manager.get(id);
        if(list == null) {
            return new response.NotFound('list "${listHash}"');
        }

        var items:List<models.Item> = models.Item.manager.search($lid == list.id);
        if(items == null) items = new List<models.Item>();

        return new response.API(api.Items.fromDBItems(items).hideReservedStatus());
    }

    @:post('/') public function newList(body:{name:String, ?privacy:TPrivacy}, user:JWTSession.User):Response {
        var u:models.User = models.User.manager.get(user.id);
        if(u == null) return new response.NotFound();

        if(body.name == null || body.name.trim().length < 1) return new response.MalformedRequest();

        var list:models.List = new models.List();
        list.name = body.name;
        list.user = u;
        list.createdOn = Date.now();
        list.modifiedOn = Date.now();
        list.privacy = switch(body.privacy) {
            case Public: Public;
            case Friends: Friends;
            case _: Private;
        };
        list.insert();

        Log.info('${u.name} (${u.id}) created a new list called "${list.name}" (privacy: ${list.privacy})!');
        return new response.API<api.List>(list);
    }

    @:post('/$listHash') public function newItem(listHash:String, body:{name:String, ?url:String, ?comments:String, ?picture:FormFile, ?reservable:Bool}, user:JWTSession.User):Response {
        var id:Int = try { Server.extractID(listHash, Server.listHID); } catch(e:Dynamic) return new response.NotFound();

        // ensure the list exists
        var list:models.List = models.List.manager.get(id);
        if(list == null) {
            return new response.NotFound('list "${listHash}"');
        }

        // ensure the user owns this list
        if(list.user.id != user.id) {
            return new response.Unauthorized();
        }

        var item:models.Item = new models.Item();
        item.list = list;
        item.name = body.name;
        item.url = body.url;
        item.comments = body.comments;
        item.reservable = switch(body.reservable) {
            case false: false;
            case _: true;
        };
        item.createdOn = Date.now();
        item.modifiedOn = Date.now();
        item.insert();
        
        if(body.picture != null) {
            var extension:String = body.picture.fileName.extension().toLowerCase();
            var fileName:String = Server.uploadsHID.encode(item.id) + '.' + extension;

            var saveName:String = (Server.config.uploads.savePath + '/' + fileName).normalize();
            var publicName:String = (Server.config.uploads.pathPrefix + '/' + fileName).normalize();

            item.image_path = publicName;
            item.update();

            body.picture.saveTo(saveName)
            .handle(function(outcome) {
                switch(outcome) {
                    case Success(_): Log.info('Saved uploaded file to: ' + saveName);
                    case Failure(error): Log.warn('Failed to upload file to: ' + saveName);
                }
            });
        }

        Log.info('Added item "${item.name}" to user ${user.id}\'s list "${list.name}" (${list.id})!');
        return new response.API<api.Item>(item);
    }

    @:patch('/$listHash') public function updateList(listHash:String, body:{?name:String, ?privacy:TPrivacy}, user:JWTSession.User):Response {
        var lid:Int = try { Server.extractID(listHash, Server.listHID); } catch(e:Dynamic) return new response.NotFound();

        // ensure the list exists
        var list:models.List = models.List.manager.get(lid);
        if(list == null) {
            return new response.NotFound('list "${listHash}"');
        }

        // ensure the user owns this list
        if(list.user.id != user.id) {
            return new response.Unauthorized();
        }

        // update it!
        var modified:Bool = false;
        if(body.name != null && body.name.trim().length > 0) {
            list.name = body.name;
            modified = true;
        }
        if(body.privacy != null && [Public, Friends, Private].indexOf(body.privacy) != -1) {
            list.privacy = body.privacy;
            modified = true;
        }

        if(modified) {
            list.update();
            Log.info('${list.user.name} updated their list "${list.name}"! ' + haxe.Json.stringify(body));
        }

        return new response.API<api.List>(list);
    }

    @:delete('/$listHash') public function deleteList(listHash:String, user:JWTSession.User):Response {
        var lid:Int = try { Server.extractID(listHash, Server.listHID); } catch(e:Dynamic) return new response.NotFound();

        // ensure the list exists
        var list:models.List = models.List.manager.get(lid);
        if(list == null) {
            return new response.NotFound('list "${listHash}"');
        }

        // ensure the user owns this list
        if(list.user.id != user.id) {
            return new response.Unauthorized();
        }

        Log.info('User ${user.id} deleted list ${list.name} (${list.id})!');

        // delete it!
        list.delete();

        return new response.API<api.Message>('List deleted!');
    }
}