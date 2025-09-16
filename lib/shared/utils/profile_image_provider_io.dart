import 'dart:io';
import 'package:flutter/material.dart';

ImageProvider fileImageImpl(String path) => FileImage(File(path));
