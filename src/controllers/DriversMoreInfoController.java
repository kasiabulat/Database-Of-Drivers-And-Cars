package controllers;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.TextArea;
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
	public void showInfo (final ActionEvent event) {
		// TODO: showing info about chosen driver
	}
}
