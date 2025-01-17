local encoder_hidden_size = 128;
local embedding_dim = 300;
local batch_size = 64;

{
    "dataset_reader": {
        "type": "snli"
    },
    "train_data_path": std.join("/", [std.extVar("PWD"), "datasets/SNLI/snli_1.0_train.jsonl"]),
    "test_data_path": std.join("/", [std.extVar("PWD"), "datasets/SNLI/snli_1.0_test.jsonl"]),
    "validation_data_path": std.join("/", [std.extVar("PWD"), "datasets/SNLI/snli_1.0_dev.jsonl"]),
    "evaluate_on_test": true,
    "model": {
        "type": "pair_sequence_classifier",
        "word_embeddings": {
            "token_embedders": {
                "tokens": {
                    "type": "embedding",
                    "pretrained_file": "https://dl.fbaipublicfiles.com/fasttext/vectors-english/wiki-news-300d-1M.vec.zip",
                    "embedding_dim": embedding_dim,
                    "trainable": true
                }
            }
        },
        "encoder": {
            "type": "lstm",
            "bidirectional": true,
            "input_size": embedding_dim,
            "hidden_size": encoder_hidden_size,
            "num_layers": 1,
        },
        "decoder": {
            "input_dim": encoder_hidden_size * 8,
            "num_layers": 1,
            "hidden_dims": 3,
            "activations": ["linear"]
        },
        "attention": {
            "type": "additive_basic",
            "hidden_size": encoder_hidden_size * 2,
            "activation_function": {
                "type": "softmax"
            }
        },
        "field_names": ["premise", "hypothesis"],
    },
    "data_loader": {
        "batch_sampler": {
            "type": "bucket",
            "batch_size": batch_size
        }
    },
    "trainer": {
        "num_epochs": 40,
        "patience": 5,
        "validation_metric": "+accuracy",
        "optimizer": {
            "type": "adam",
            "weight_decay": 1e-5,
            "amsgrad": true
        }
    },
    "attention_experiment": {
        "feature_importance_measures": [
            {
                "type": "captum",
                "captum": {
                    "type": "captum-lime",
                    "attribute_args": {
                        "n_samples": 1000
                    }
                }
            },
            {
                "type": "captum",
                "captum": "captum-integrated-gradients"
            },
            {
                "type": "captum",
                "captum": "captum-deepliftshap"
            },
            {
                "type": "captum",
                "captum": "captum-gradientshap"
            },
            {
                "type": "captum",
                "captum": "captum-deeplift"
            }
        ],
        "correlation_measures": [
            {
                "type": "kendall_tau"
            },
            {
                "type": "spearman_rho"
            },
            {
                "type": "pearson_r"
            },
            {
                "type": "kendall_top_k_variable",
                "percent_top_k": [
                    0.25,
                    0.5,
                    1.0
                ],
            },
            {
                "type": "kendall_top_k_fixed",
                "fixed_top_k": [
                    5,
                    10
                ],
            }
        ],
        "dataset": "SNLI",
        "model": "BiLSTM",
        "compatibility_function": "Additive (tanh)",
        "activation_function": "Softmax",
        "batch_size": batch_size,
        "nr_instances": 500
    }
}
