class Store {
    public static var auth(default, null):stores.AuthStore = new stores.AuthStore();
    public static var profile(default, null):stores.ProfileStore = new stores.ProfileStore();
    public static var friends(default, null):stores.FriendsStore = new stores.FriendsStore();
    public static var lists(default, null):stores.ListsStore = new stores.ListsStore();
}