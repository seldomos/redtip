/* listrow.vala
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

namespace Redtip {

	[GtkTemplate (ui = "/com/github/seldomos/redtip/ui/service_row.ui")]
	public class ServiceRow : Gtk.ListBoxRow {

		[GtkChild]
		public unowned Gtk.Label label_service_name;

		[GtkChild]
		public unowned Gtk.Label label_service_unit_name;

		[GtkChild]
		public unowned Gtk.Label label_service_description;

		[GtkChild]
		public unowned Gtk.Switch switch_service;

		[GtkChild]
		public unowned Gtk.MenuButton button_menu_service;

		[GtkChild]
		public unowned Gtk.ModelButton button_restart_service;

		[GtkChild]
		public unowned Gtk.ModelButton button_reload_service;

		[GtkChild]
		public unowned Gtk.Separator separator_menu_service_1;

		[GtkChild]
		public unowned Gtk.ModelButton button_rename_service;

		[GtkChild]
		public unowned Gtk.ModelButton button_delete_service;

		private Gtk.Window window;
		public Service service;
		public Systemd.Unit? unit = null;
		public Systemd.Properties? prop = null;

		public ServiceRow(Gtk.Window window, Service service) {
			this.window = window;
			this.service = service;
			try {
				unit = Bus.get_proxy_sync(
					BusType.SYSTEM,
					"org.freedesktop.systemd1",
					App.manager.load_unit(service.unit_name));

				if (unit.fragment_path != "") {
					button_restart_service.clicked.connect(() => {
						restart_service();
					});

					button_reload_service.clicked.connect(() => {
						reload_service();
					});

					prop = Bus.get_proxy_sync(
						BusType.SYSTEM,
						"org.freedesktop.systemd1",
						App.manager.load_unit(service.unit_name));
					prop.properties_changed.connect(on_props_changed);
				}
			} catch (Error e) {
				print(@"$(e.message)\n");
			}

			reload_widget();
		}

		public void reload_widget() {
			label_service_name.set_markup (
				@"<b>$(service.name)</b>"
			);
			label_service_unit_name.set_markup (
			    @"<small>($(service.unit_name))</small>"
			);
			switch_service.notify["active"].disconnect(on_switch_service_active);

			if (unit.active_state == "active") {
				switch_service.active = true;
				button_restart_service.show();
				if (unit.can_reload == true) {
					button_reload_service.show();
				}
				separator_menu_service_1.show();
			} else {
				switch_service.active = false;
				button_restart_service.hide();
				button_reload_service.hide();
				separator_menu_service_1.hide();
			}

			if (unit.fragment_path != "") {
				label_service_description.set_markup(
					@"<small>$(unit.description)</small>"
				);
				switch_service.sensitive = true;
				switch_service.notify["active"].connect(on_switch_service_active);
			} else {
				label_service_name.set_markup(@"<i><b>$(service.name)</b></i>");
				label_service_unit_name.set_markup(
					@"<i><small>($(service.unit_name))</small></i>"
				);
				label_service_description.set_markup(
					"<i><small>(service not found)</small></i>"
				);
				switch_service.sensitive = false;
			}
		}

		public void on_switch_service_active(GLib.Object object, ParamSpec param) {
			var sw_service = (Gtk.Switch) object;
			if (sw_service.active) {
				start_service();
			} else {
				stop_service();
			}
		}

		public void on_props_changed(string iface,
									 HashTable <string, Variant> changed,
									 string[] invalidated) {
			if (iface == "org.freedesktop.systemd1.Unit") {
				changed.foreach ((k,v) => {
					if (k == "ActiveState") {
						bool? state = null;
						if ((string) v == "active") {
							state = true;
						} else if ((string) v == "inactive") {
							state = false;
						}
						if (state != null) {
							if (switch_service.active != state) {
								Timeout.add(100, () => { reload_widget(); return false; });
							}
						}
					}
				});
			}
		}

		public void start_service() {
			try {
				print(@"start '$(service.unit_name)'\n");
				unit.start("replace");
			} catch (Error e) {
				show_error_dialog(window, e);
				Timeout.add(50, () => { reload_widget(); return false; });
			}
		}

		public void restart_service() {
			try {
				print(@"restart '$(service.unit_name)'\n");
				unit.restart("replace");
			} catch (Error e) {
				show_error_dialog(window, e);
			}
		}

		public void stop_service() {
			try {
				print(@"stop '$(service.unit_name)'\n");
				unit.stop("replace");
			} catch (Error e) {
				show_error_dialog(window, e);
				Timeout.add(50, () => { reload_widget(); return false; });
			}
		}

		public void reload_service() {
			try {
				print(@"reload '$(service.unit_name)'\n");
				unit.reload("replace");
			} catch (Error e) {
				show_error_dialog(window, e);
			}
		}
	}
}
