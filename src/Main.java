import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;

import java.io.IOException;

public class Main extends Application {

    public static void main(final String[] args) {
        launch(args);
    }

    @Override
    public void start(final Stage primaryStage) throws IOException {
        final Parent root = FXMLLoader.load(getClass().getResource("FXML/mainWindow.fxml"));
        primaryStage.setTitle("System ewidencji pojazdów i kierowców");
        primaryStage.setScene(new Scene(root, 300, 220));
        primaryStage.show();
    }
}
