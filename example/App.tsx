import { Button, StyleSheet, Text, View } from "react-native";
import * as ExpoPdfText from "expo-pdf-text";
import * as DocumentPicker from "expo-document-picker";
import { useEffect, useState } from "react";

export default function App() {
  const [uri, setUri] = useState(null);
  const pickDocument = async () => {
    const doc = await DocumentPicker.getDocumentAsync();
    console.log(doc);
    setUri(doc.assets[0].uri);
  };

  const handleParse = async (uri: string) => {
    const result = await ExpoPdfText.parsePdf(uri);
    console.log(result);

    return result;
  };

  useEffect(() => {
    if (uri) {
      handleParse(uri);
    }
  }, [uri]);

  return (
    <View style={styles.container}>
      <Button title="Pick" onPress={pickDocument} />
      <Button
        title="Parse from web url"
        onPress={() => {
          setUri(
            "https://unec.edu.az/application/uploads/2014/12/pdf-sample.pdf",
          );
        }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#fff",
    alignItems: "center",
    justifyContent: "center",
  },
});
