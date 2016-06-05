package controllers;

import database.Database;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.TextArea;
import javafx.scene.control.TextField;
import javafx.scene.layout.AnchorPane;

public class DriversMoreInfoController {
	// TODO: add fields in controller, add more/change fields in window?
	@FXML
	private AnchorPane anchorPane;

	@FXML
	private Button showInfo;

	@FXML
	private TextArea ilość_punktów_karnych;

	@FXML
	private TextArea ilość_mandatów;

	@FXML
	private TextArea ostatni_egzamin;

	@FXML
	private TextArea prawa_jazdy;

	@FXML
	private TextArea ilość_podejść_do_egzaminu;

	@FXML
	private TextArea międzynarodowe_prawa_jazdy;

	@FXML
	private TextArea pojazdy;

	@FXML
	private TextField id_kierowcy;

	@FXML
	public void showInfo (final ActionEvent event) {
		final int kierowca=Integer.valueOf(id_kierowcy.getText());
		pojazdy.setText(Database.instance.getDriversVehicles(kierowca));
		prawa_jazdy.setText(Database.instance.getDriverSimpleStringInformation("SELECT nr_prawa_jazdy(?)",kierowca));
		międzynarodowe_prawa_jazdy.setText(Database.instance.getDriverSimpleStringInformation("SELECT nr_prawa_jazdy_M(?)",kierowca));
		ilość_mandatów.setText(Database.instance.getDriverSimpleStringInformation("SELECT ilosc_mandatow(?)",kierowca));
		ilość_punktów_karnych.setText(Database.instance.getDriverSimpleStringInformation("SELECT ile_punktow(?)",kierowca));
		ilość_podejść_do_egzaminu.setText(Database.instance.getDriverSimpleStringInformation("SELECT ilosc_egzaminow(?)",kierowca));
		ostatni_egzamin.setText(Database.instance.getDriverSimpleStringInformation("SELECT ostatni_egzamin(?)",kierowca));
	}
}
