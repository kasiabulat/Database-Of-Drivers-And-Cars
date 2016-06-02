package controllers;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.TableView;
import javafx.stage.Stage;

import java.io.IOException;

public class DriversController {
	// TODO: add fields
	@FXML
	private TableView tableView;
	@FXML
	private Button addButton;
	@FXML
	private Button moreInfoButton;
	@FXML
	public void addDriver (final ActionEvent event) {
		// TODO: adding driver to database
	}
	@FXML
	public void showMoreInfo (final ActionEvent event) {
		try {
			final Parent root= FXMLLoader.load(getClass().getResource("../FXML/driversMoreInfoWindow.fxml"));
			final Stage stage=new Stage();
			stage.setTitle("Kierowcy - szczegółowe informacje");
			stage.setScene(new Scene(root,450,310));
			stage.show();

		} catch(final IOException e) {
			e.printStackTrace();
		}
	}
}
