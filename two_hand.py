import cv2
import mediapipe as mp
import numpy as np

mp_hands = mp.solutions.hands
mp_draw = mp.solutions.drawing_utils

def extract_hand_features(hand_landmarks):
    wrist = hand_landmarks.landmark[0]
    middle_tip = hand_landmarks.landmark[12]

    scale = np.sqrt((middle_tip.x - wrist.x) ** 2 + (middle_tip.y - wrist.y) ** 2)
    if scale == 0:
        return None

    lm_list = []
    for lm in hand_landmarks.landmark:
        lm_list.extend([
            (lm.x - wrist.x) / scale,
            (lm.y - wrist.y) / scale,
            (lm.z - wrist.z) / scale
        ])
    return lm_list  # 63 values

cap = cv2.VideoCapture(0)

with mp_hands.Hands(
    max_num_hands=2,
    min_detection_confidence=0.7,
    min_tracking_confidence=0.7
) as hands:

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        frame = cv2.flip(frame, 1)
        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = hands.process(rgb)

        hand1 = [0.0] * 63
        hand2 = [0.0] * 63

        detected_hands = []

        if results.multi_hand_landmarks:
            for hand_landmarks in results.multi_hand_landmarks:
                feats = extract_hand_features(hand_landmarks)
                if feats is not None:
                    wrist_x = hand_landmarks.landmark[0].x
                    detected_hands.append((wrist_x, feats, hand_landmarks))

            # Sort by screen position, not Right/Left classification
            detected_hands.sort(key=lambda x: x[0])

            if len(detected_hands) >= 1:
                hand1 = detected_hands[0][1]
            if len(detected_hands) >= 2:
                hand2 = detected_hands[1][1]

            # Draw detected hands
            for i, (_, _, hand_landmarks) in enumerate(detected_hands[:2]):
                mp_draw.draw_landmarks(frame, hand_landmarks, mp_hands.HAND_CONNECTIONS)

                # Label as Hand1 / Hand2
                h, w, _ = frame.shape
                cx = int(hand_landmarks.landmark[0].x * w)
                cy = int(hand_landmarks.landmark[0].y * h)

                cv2.putText(
                    frame,
                    f"Hand{i+1}",
                    (cx, cy - 10),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.8,
                    (0, 255, 0),
                    2
                )

        row = hand1 + hand2  # 126 features total

        # Debug info on screen
        detected_count = 0
        if any(v != 0.0 for v in hand1):
            detected_count += 1
        if any(v != 0.0 for v in hand2):
            detected_count += 1

        cv2.putText(
            frame,
            f"Detected Hands: {detected_count}",
            (20, 40),
            cv2.FONT_HERSHEY_SIMPLEX,
            1,
            (255, 0, 0),
            2
        )

        cv2.putText(
            frame,
            "Press Q to quit",
            (20, 80),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.8,
            (0, 0, 255),
            2
        )

        print("Hand1 detected:", any(v != 0.0 for v in hand1),
              "| Hand2 detected:", any(v != 0.0 for v in hand2))

        cv2.imshow("Two-Hand Test", frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

cap.release()
cv2.destroyAllWindows()