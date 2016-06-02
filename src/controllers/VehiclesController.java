package controllers;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.TableView;
import javafx.scene.image.Image;
import javafx.scene.layout.*;

import java.io.File;

public class VehiclesController {
	@FXML
	private TableView tableView;
	@FXML
	private Button addButton;
	@FXML
	private Button moreInfoButton;
	@FXML
	public void addVehicle (final ActionEvent event) {
		// TODO: adding vehicle to database
	}
	@FXML
	public void showMoreInfo (final ActionEvent event) {
		// TODO: show more info about vehicles - some statistic, how many cars in each type, itp.
	}
}
