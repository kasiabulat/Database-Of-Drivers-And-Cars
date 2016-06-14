package controllers;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.image.Image;
import javafx.scene.layout.*;
import javafx.stage.Stage;

import java.io.File;
import java.io.IOException;

public class OwnersChoiceController {
    @FXML
    private AnchorPane anchorPane;
    @FXML
    private Button firmsButton;
    @FXML
    private Button driversButton;

    @FXML
    public void showFirms(final ActionEvent event) {
        try {
            final Parent root = FXMLLoader.load(getClass().getResource("../FXML/firmsWindow.fxml"));
            final Stage stage = new Stage();
            stage.setTitle("Firmy");
            stage.setScene(new Scene(root, 610, 500));
            stage.show();

        } catch (final IOException e) {
            e.printStackTrace();
        }
    }

    @FXML
    public void showDrivers(final ActionEvent event) {
        try {
            final Parent root = FXMLLoader.load(getClass().getResource("../FXML/driversWindow.fxml"));
            final Stage stage = new Stage();
            stage.setTitle("Kierowcy");
            stage.setScene(new Scene(root, 610, 500));
            stage.show();

        } catch (final IOException e) {
            e.printStackTrace();
        }
    }

    @FXML
    public void initialize() {
        Image bg = new Image((new File("images/car2.jpg")).toURI().toString());
        anchorPane.setBackground(new Background(new BackgroundImage(bg, BackgroundRepeat.NO_REPEAT, BackgroundRepeat.NO_REPEAT, BackgroundPosition.CENTER, BackgroundSize.DEFAULT)));

    }
}
