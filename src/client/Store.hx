import tink.state.State;
import tink.state.ObservableArray;
import tink.state.ObservableMap;
import haxe.ds.StringMap;
import api.Profile;
import api.List;
import api.Item;
import types.IDProfile;
import types.IDList;
import types.IDItem;
import types.APIPromised;
import types.APIArray;

class Store {
    // auth
    public static var token(default, null):State<String> = new State<String>(null);
    public static var uid(default, null):State<String> = new State<String>(null);
    public static var profile(default, null):State<APIPromised<IDProfile>> = Uninitialized;

    // raw data
    public static var profiles(default, null):StringMap<Profile> = new StringMap<Profile>();
    public static var lists(default, null):StringMap<List> = new StringMap<List>();
    public static var items(default, null):StringMap<Item> = new StringMap<Item>();

    // friends
    public static var incomingFriendRequests(default, null):APIArray<IDProfile> = new APIArray<IDProfile>();
    public static var sentFriendRequests(default, null):APIArray<IDProfile> = new APIArray<IDProfile>();
    public static var friends(default, null):APIArray<IDProfile> = new APIArray<IDProfile>();

    // relations
    public static var profileLists(default, null):ObservableMap<IDProfile, ObservableArray<IDList>> = new ObservableMap<IDProfile, ObservableArray<IDList>>(new StringMap<ObservableArray<IDList>>());
    public static var listItems(default, null):ObservableMap<IDList, ObservableArray<IDItem>> = new ObservableMap<IDList, ObservableArray<IDItem>>(new StringMap<ObservableArray<IDItem>>());

    // TODO: move these somewhere sane
    // utilities
    public static function getListProfile(id:IDList):Null<IDProfile> {
        for(profileID in profileLists.keys()) {
            for(listID in profileLists.get(profileID)) {
                if(listID == id) return profileID;
            }
        }
        return null;
    }

    public static function getItemList(id:IDItem):Null<IDList> {
        for(listID in listItems.keys()) {
            for(itemID in listItems.get(listID)) {
                if(itemID == id) return listID;
            }
        }
        return null;
    }
}