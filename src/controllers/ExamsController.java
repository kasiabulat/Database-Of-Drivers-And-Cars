package controllers;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.TableView;

public class ExamsController {
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
	public void addResult (final ActionEvent event) {
		// TODO: adding result of the exam to database
	}
	@FXML
	public void showMoreInfo (final ActionEvent event) {
		// TODO: show more info about the exam using all tables - wyniki_egzaminów,egzaminy,ośrodki,egzaminatorzy
	}
	@FXML
	public void showStatistics (final ActionEvent event) {
		// TODO: show some statictics about exams, how many drivers had passed etc.
	}
}
