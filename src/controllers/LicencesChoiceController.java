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

public class LicencesChoiceController {
    @FXML
    private AnchorPane anchorPane;
    @FXML
    private Button examsButton;
    @FXML
    private Button moreInfoButton;

    @FXML
    public void showExams(final ActionEvent event) {
        try {
            final Parent root = FXMLLoader.load(getClass().getResource("../FXML/examsWindow.fxml"));
            final Stage stage = new Stage();
            stage.setTitle("Egzaminy");
            stage.setScene(new Scene(root, 610, 500));
            stage.show();

        } catch (final IOException e) {
            e.printStackTrace();
        }
    }

    @FXML
    public void showMoreInfo(final ActionEvent event) {
        // TODO: show more info and some statistics about licences using tables prawa_jazdy, prawa_jazdy_kategorie
    }

    @FXML
    public void initialize() {
        Image bg = new Image((new File("images/car2.jpg")).toURI().toString());
        anchorPane.setBackground(new Background(new BackgroundImage(bg, BackgroundRepeat.NO_REPEAT, BackgroundRepeat.NO_REPEAT, BackgroundPosition.CENTER, BackgroundSize.DEFAULT)));

    }
}
