/* window.vala
 *
 * Copyright 2021 Abdul Munif Hanafi
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Ketip {

	[GtkTemplate (ui = "/io/github/hahnavi/Ketip/window.ui")]
	public class Window : Gtk.ApplicationWindow {

	    [GtkChild]
	    private unowned Gtk.Popover popover_add_service;

		[GtkChild]
	    private unowned Gtk.Entry entry_service_name;

		[GtkChild]
	    private unowned Gtk.Entry entry_unit_name;

		[GtkChild]
	    private unowned Gtk.Button button_add_add_service;

		[GtkChild]
		private unowned Gtk.MenuButton button_menu_main;

		[GtkChild]
		private unowned Gtk.ListBox list_box_services;

		private Systemd.Manager manager;

		public Window (Gtk.Application app) {
			Object (application: app);
			try {
				manager = Bus.get_proxy_sync(
					BusType.SYSTEM,
					"org.freedesktop.systemd1",
					"/org/freedesktop/systemd1");
			} catch (IOError e) {
				print(e.message);
			}
			var menu_main = new Menu();
			menu_main.append("About Ketip", "app.about");
			button_menu_main.menu_model = menu_main;
			save_and_reload_list();
		}

		private Gtk.Widget create_list_row(Object serviceObj) {
			var service = (Service) serviceObj;
			var row = new ServiceRow(service);
			var menu_service = new Gtk.Menu ();
			var menu_item = new Gtk.MenuItem.with_label("Restart");
			menu_item.activate.connect(() => {
				restart_service(service.unit_name);
			});
			menu_service.add(menu_item);
			menu_item = new Gtk.MenuItem.with_label("Rename");
			menu_item.activate.connect(() => {
			    print("Renaming...");
			});
			menu_service.add(menu_item);
			menu_item = new Gtk.MenuItem.with_label("Delete");
			menu_item.activate.connect(() => {
			    var dialog = new Gtk.MessageDialog(
			        this,
			        Gtk.DialogFlags.DESTROY_WITH_PARENT,
			        Gtk.MessageType.QUESTION,
			        Gtk.ButtonsType.YES_NO,
			        @"Are you sure you want to delete '$(service.name)' from the list?"
			    );
			    dialog.format_secondary_text(@"($(service.unit_name))");
			    var response = dialog.run();
			    if (response == Gtk.ResponseType.YES) {
				    App.services_model.remove(service);
				    save_and_reload_list();
				}
			    dialog.destroy();
			});
			menu_service.add(menu_item);
			menu_service.show_all();
			row.button_menu_service.popup = menu_service;

			try {
				Systemd.Unit u = Bus.get_proxy_sync(
					BusType.SYSTEM,
					"org.freedesktop.systemd1",
					manager.load_unit(service.unit_name));
				if (u.active_state == "active") {
					row.switch_service.active = true;
				} else {
					row.switch_service.active = false;
				}
				row.switch_service.notify["active"].connect(() => {
					if (row.switch_service.active) {
						start_service(service.unit_name);
					} else {
						stop_service(service.unit_name);
					}
				});
				row.label_service_description.set_markup(
					@"<small>$(u.description)</small>"
				);
			} catch (Error e) {
				print(e.message);
			}

			return row;
		}

		private void start_service(string unit_name) {
			Systemd.Unit u = null;

			try {
				u = Bus.get_proxy_sync(
					BusType.SYSTEM,
					"org.freedesktop.systemd1",
					manager.load_unit(unit_name));
			} catch (Error e) {
				show_error(e);
			}

			if (u == null)
				return;

			try {
				u.start("replace");
			} catch (Error e) {
				show_error(e);
			}
		}

		public void stop_service(string unit_name) {
			Systemd.Unit u = null;

			try {
				u = Bus.get_proxy_sync(
					BusType.SYSTEM,
					"org.freedesktop.systemd1",
					manager.load_unit(unit_name));
			} catch (Error e) {
				show_error(e);
			}

			if (u == null)
				return;

			try {
				u.stop("replace");
			} catch (Error e) {
				show_error(e);
			}
		}

		public void restart_service(string unit_name) {
			Systemd.Unit u = null;

			try {
				u = Bus.get_proxy_sync(
					BusType.SYSTEM,
					"org.freedesktop.systemd1",
					manager.load_unit(unit_name));
			} catch (Error e) {
				show_error(e);
			}

			if (u == null)
				return;

			try {
				u.restart("replace");
			} catch (Error e) {
				show_error(e);
			}
		}

		public void show_error(Error e) {
			var message_dialog = new Gtk.MessageDialog(this,
				Gtk.DialogFlags.DESTROY_WITH_PARENT,
				Gtk.MessageType.ERROR,
				Gtk.ButtonsType.CLOSE, e.message);
			message_dialog.title = "Error";
			message_dialog.run();
			message_dialog.destroy();
		}

		[GtkCallback]
		private void entry_service_name_add_service_changed(Gtk.Editable editable) {
		    if ((entry_service_name.text != "")
		            && (entry_unit_name.text != "")
		            && (entry_unit_name.text.has_suffix(".service"))) {
                button_add_add_service.sensitive = true;
		    } else {
		        button_add_add_service.sensitive = false;
		    }
		}

		[GtkCallback]
		private void button_cancel_add_service_clicked(Gtk.Button button) {
            popover_add_service.popdown();
            clear_form_add_service();
		}

		[GtkCallback]
		private void button_add_add_service_clicked(Gtk.Button button) {
		    var service = new Service(
	            entry_service_name.text,
	            entry_unit_name.text
            );
	        App.services_model.add(service);
	        save_and_reload_list();
            popover_add_service.popdown();
            clear_form_add_service();
		}

		private void clear_form_add_service() {
		    entry_service_name.text = "";
            entry_unit_name.text = "";
		}

		private void save_and_reload_list() {
			save_config_file();
			list_box_services.bind_model(App.services_model, create_list_row);
			list_box_services.show_all();
		}
	}
}