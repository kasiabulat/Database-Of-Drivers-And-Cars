package controllers;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.TableView;

public class OffencesController {
	//TODO: add fields
	@FXML
	private TableView tableView;
	@FXML
	private Button addButton;
	@FXML
	private Button moreInfoButton;
	@FXML
	private Button statisticsButton;
	@FXML
	public void addOffence (final ActionEvent event) {
		// TODO: adding offence to database
	}
	@FXML
	public void showMoreInfo (final ActionEvent event) {
		// TODO: show more info basing on all three tables - mandaty_wystawiający, wykroczenia, mandaty
	}
	@FXML
	public void showStatistics (final ActionEvent event) {
		// TODO: show how many offences in each type had been committed, how many which officer had registered etc.
	}
}
