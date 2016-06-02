package controllers;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.TableView;
import javafx.scene.image.Image;
import javafx.scene.layout.*;
import javafx.stage.Stage;

import java.io.File;
import java.io.IOException;

public class MainController {
	@FXML
	private AnchorPane anchorPane;
	@FXML
	private Button driversButton;
	@FXML
	private Button vehiclesButton;
	@FXML
	private Button licencesButton;
	@FXML
	private Button offencesButton;

	@FXML
	public void showVehicles (final ActionEvent event) {
		try {
			final Parent root= FXMLLoader.load(getClass().getResource("../FXML/vehiclesWindow.fxml"));
			final Stage stage=new Stage();
			stage.setTitle("Pojazdy");
			stage.setScene(new Scene(root,490,500));
			stage.show();

		} catch(final IOException e) {
			e.printStackTrace();
		}
	}

	@FXML
	public void showOffences (final ActionEvent event) {
		try {
			final Parent root= FXMLLoader.load(getClass().getResource("../FXML/offencesWindow.fxml"));
			final Stage stage=new Stage();
			stage.setTitle("Wyroczenia");
			stage.setScene(new Scene(root,490,500));
			stage.show();

		} catch(final IOException e) {
			e.printStackTrace();
		}
	}

	@FXML
	public void showLicences (final ActionEvent event) {
		try {
			final Parent root= FXMLLoader.load(getClass().getResource("../FXML/licencesChoiceWindow.fxml"));
			final Stage stage=new Stage();
			stage.setTitle("Prawa jazdy");
			stage.setScene(new Scene(root,300,220));
			stage.show();

		} catch(final IOException e) {
			e.printStackTrace();
		}
	}

	@FXML
	public void showDrivers (final ActionEvent event) {
		try {
			final Parent root= FXMLLoader.load(getClass().getResource("../FXML/driversWindow.fxml"));
			final Stage stage=new Stage();
			stage.setTitle("Kierowcy");
			stage.setScene(new Scene(root,610,500));
			stage.show();

		} catch(final IOException e) {
			e.printStackTrace();
		}
	}

	@FXML
	public void initialize() {
		Image bg = new Image((new File("images/car2.jpg")).toURI().toString());
		anchorPane.setBackground(new Background(new BackgroundImage(bg, BackgroundRepeat.NO_REPEAT,BackgroundRepeat.NO_REPEAT, BackgroundPosition.CENTER,BackgroundSize.DEFAULT)));

	}

}
